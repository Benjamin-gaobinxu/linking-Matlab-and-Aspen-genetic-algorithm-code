clear;
[filename,filepath]=uigetfile('C:\Users\dell\Desktop\高彬栩\科研启动项目（5.2）\ASPEN\输出结果整理\一个加再热器的结构\混合工质讨论\C2H6+CHF3\遗传算法优化\C2H6+CHF3(混合工质 GA优化3.1).apwz'); 
handles.aspen = actxserver('Apwn.Document'); 
handles.filepathname=strcat(filepath,filename); 
handles.aspen.InitFromFile2(handles.filepathname); 
handles.aspen.Visible=0; 
aspen=handles.aspen; 
tic
%怎么把q和w的关系相互结合起来  改变q的值就会改变w的值 aspen.Run2
%定义遗传算法参数
NIND=40;    %个体数目(Number of individuals)
MAXGEN=25;  %最大遗传代数(Maximum number of generations)
NVAR=2;     %变量数目
PRECI=100;   %变量的二进制位数(Precision of variables)
GGAP=0.9;   %代沟(Generation gap)
%建立区域描述器(Build field descriptor)
FieldD=[rep(PRECI,[1,NVAR]);[1000,1000;3000,3000];rep([1;0;1;1],[1,NVAR])];%变量范围
%FieldD=[rep(PRECI,[1,NVAR]);rep([340;3060],[1,NVAR]);rep([1;0;1;1],[1,NVAR])];
Chrom=crtbp(NIND,NVAR*PRECI);%创建子代
trace=zeros(MAXGEN,2);%遗传算法性能跟踪初始值
x=bs2rv(Chrom,FieldD);%初始种群十进制转换
w=zeros(NIND,1);
for i=1:NIND
    aspen.Tree.FindNode('\Data\Streams\COOD2-OU\Input\TOTFLOW\MIXED').value=x(i,1);%变量1
    aspen.Tree.FindNode('\Data\Streams\COOD-OUT\Input\TOTFLOW\MIXED').value=x(i,2);%变量2
%     aspen.Tree.FindNode('\Data\Blocks\PUMP\Input\PRES').value=x(i,3);
%     aspen.Tree.FindNode('\Data\Blocks\PUMP2\Input\PRES').value=x(i,4);
%     aspen.Tree.FindNode('\Data\Blocks\EVAP\Input\TEMP').value=x(i,5);
    Reinit(aspen)
    aspen.Run2   %把值赋给q，返回到Aspen中重新计算w的值
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
 gen=0;   %创建初始种群gen=0;
ObjV=w;   %计算初始种群的目标函数值
w1=zeros(NIND*GGAP,1);
while gen<MAXGEN
    FitnV=ranking(ObjV);%分配适应度值
    SelCh=select('sus',Chrom,FitnV,GGAP);%选择
    SelCh=recombin('xovsp',SelCh,0.7);%重组
    SelCh=mut(SelCh);%变异
    c=bs2rv(SelCh,FieldD);%子代十进制转换
    
    for j=1:NIND*GGAP
          aspen.Tree.FindNode('\Data\Streams\COOD2-OU\Input\TOTFLOW\MIXED').value=c(j,1);%变量1
          aspen.Tree.FindNode('\Data\Streams\COOD-OUT\Input\TOTFLOW\MIXED').value=c(j,2);%变量2
%           aspen.Tree.FindNode('\Data\Blocks\PUMP\Input\PRES').value=c(j,3);
%           aspen.Tree.FindNode('\Data\Blocks\PUMP2\Input\PRES').value=c(j,4);
%           aspen.Tree.FindNode('\Data\Blocks\EVAP\Input\TEMP').value=c(j,5);
          Reinit(aspen)
          aspen.Run2   %把值赋给q，返回到Aspen中重新计算w的值
           % d=aspen.Tree.FindNode('\Data\Blocks\TURBINE\Output\BRAKE_POWER').value;%读取output的值
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
    ObjVSel=w1;%重插入
    [Chrom,ObjV]=reins(Chrom,SelCh,1,1,ObjV,ObjVSel);
    gen=gen+1;
    [Y,I]=min(ObjVSel);%输出最优解及其对应的自变量
    Y
    bs2rv(Chrom(I,:),FieldD)
    trace(gen,1)=min(ObjV);
    trace(gen,2)=sum(ObjV)/length(ObjV);%遗传算法性能跟踪
end 
toc