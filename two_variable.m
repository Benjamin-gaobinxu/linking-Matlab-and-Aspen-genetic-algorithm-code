clear;
[filename,filepath]=uigetfile('C:\Users\dell\Desktop\�߱���\����������Ŀ��5.2��\ASPEN\����������\һ�����������Ľṹ\��Ϲ�������\C2H6+CHF3\�Ŵ��㷨�Ż�\C2H6+CHF3(��Ϲ��� GA�Ż�3.1).apwz'); 
handles.aspen = actxserver('Apwn.Document'); 
handles.filepathname=strcat(filepath,filename); 
handles.aspen.InitFromFile2(handles.filepathname); 
handles.aspen.Visible=0; 
aspen=handles.aspen; 
tic
%��ô��q��w�Ĺ�ϵ�໥�������  �ı�q��ֵ�ͻ�ı�w��ֵ aspen.Run2
%�����Ŵ��㷨����
NIND=40;    %������Ŀ(Number of individuals)
MAXGEN=25;  %����Ŵ�����(Maximum number of generations)
NVAR=2;     %������Ŀ
PRECI=100;   %�����Ķ�����λ��(Precision of variables)
GGAP=0.9;   %����(Generation gap)
%��������������(Build field descriptor)
FieldD=[rep(PRECI,[1,NVAR]);[1000,1000;3000,3000];rep([1;0;1;1],[1,NVAR])];%������Χ
%FieldD=[rep(PRECI,[1,NVAR]);rep([340;3060],[1,NVAR]);rep([1;0;1;1],[1,NVAR])];
Chrom=crtbp(NIND,NVAR*PRECI);%�����Ӵ�
trace=zeros(MAXGEN,2);%�Ŵ��㷨���ܸ��ٳ�ʼֵ
x=bs2rv(Chrom,FieldD);%��ʼ��Ⱥʮ����ת��
w=zeros(NIND,1);
for i=1:NIND
    aspen.Tree.FindNode('\Data\Streams\COOD2-OU\Input\TOTFLOW\MIXED').value=x(i,1);%����1
    aspen.Tree.FindNode('\Data\Streams\COOD-OUT\Input\TOTFLOW\MIXED').value=x(i,2);%����2
%     aspen.Tree.FindNode('\Data\Blocks\PUMP\Input\PRES').value=x(i,3);
%     aspen.Tree.FindNode('\Data\Blocks\PUMP2\Input\PRES').value=x(i,4);
%     aspen.Tree.FindNode('\Data\Blocks\EVAP\Input\TEMP').value=x(i,5);
    Reinit(aspen)
    aspen.Run2   %��ֵ����q�����ص�Aspen�����¼���w��ֵ
    Stringchar=handles.aspen.Tree.FindNode('\Data\Results Summary\Run-Status\Output\PER_ERROR\2').value;
    tf=strcmp(Stringchar,'completed with errors:');
    if tf==1
       b=0;
    else
       b=aspen.Tree.FindNode('\Data\Blocks\TURBINE\Output\BRAKE_POWER').value;
    end
     w(i,1)=b;
    %b=aspen.Tree.FindNode('\Data\Blocks\TURBINE\Output\BRAKE_POWER').value;
%     if (x(i,1)+x(i,2)>=3900)&&(x(i,1)+x(i,2)<=4500)       %(x(i,1)+x(i,2)>=3400)&&(x(i,1)+x(i,2)<=3900)&&(b>-60)
%         w(i,1)=b;
%     else 
%         w(i,1)=0;
%     end
end
 gen=0;   %������ʼ��Ⱥgen=0;
ObjV=w;   %�����ʼ��Ⱥ��Ŀ�꺯��ֵ
w1=zeros(NIND*GGAP,1);
while gen<MAXGEN
    FitnV=ranking(ObjV);%������Ӧ��ֵ
    SelCh=select('sus',Chrom,FitnV,GGAP);%ѡ��
    SelCh=recombin('xovsp',SelCh,0.7);%����
    SelCh=mut(SelCh);%����
    c=bs2rv(SelCh,FieldD);%�Ӵ�ʮ����ת��
    
    for j=1:NIND*GGAP
          aspen.Tree.FindNode('\Data\Streams\COOD2-OU\Input\TOTFLOW\MIXED').value=c(j,1);%����1
          aspen.Tree.FindNode('\Data\Streams\COOD-OUT\Input\TOTFLOW\MIXED').value=c(j,2);%����2
%           aspen.Tree.FindNode('\Data\Blocks\PUMP\Input\PRES').value=c(j,3);
%           aspen.Tree.FindNode('\Data\Blocks\PUMP2\Input\PRES').value=c(j,4);
%           aspen.Tree.FindNode('\Data\Blocks\EVAP\Input\TEMP').value=c(j,5);
          Reinit(aspen)
          aspen.Run2   %��ֵ����q�����ص�Aspen�����¼���w��ֵ
           % d=aspen.Tree.FindNode('\Data\Blocks\TURBINE\Output\BRAKE_POWER').value;%��ȡoutput��ֵ
          Stringchar1={handles.aspen.Tree.FindNode('\Data\Results Summary\Run-Status\Output\PER_ERROR\2').value};
          tf=strcmp(Stringchar1,{'completed with errors:'});
        if tf==1
           d=0;
        else
           d=aspen.Tree.FindNode('\Data\Blocks\TURBINE\Output\BRAKE_POWER').value;
        end
         clear Stringchar
         clear tf
         
        w1(j,1)=d;
%            if (c(j,1)+c(j,2)>=3900)&&(c(j,1)+c(j,2)<=4500)&&(d>-60) 
%             
%           else 
%                w1(j,1)=0;
%           end   
    end
    ObjVSel=w1;%�ز���
    [Chrom,ObjV]=reins(Chrom,SelCh,1,1,ObjV,ObjVSel);
    gen=gen+1;
    [Y,I]=min(ObjVSel);%������Ž⼰���Ӧ���Ա���
    Y
    bs2rv(Chrom(I,:),FieldD)
    trace(gen,1)=min(ObjV);
    trace(gen,2)=sum(ObjV)/length(ObjV);%�Ŵ��㷨���ܸ���
end 
toc