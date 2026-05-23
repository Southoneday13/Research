function tetris
global  gameArea gameAreaColors shapes colors flag score gameTimer blockId shape color newBlockId textArea1 textArea2;
%创建UI组件
fig=uifigure('Name','tetris','Position',[500,500,640,550]);
panel=uipanel(fig,'Title','Control Panel','Position',[330,45,240,240]);
startButton=uibutton(panel,'push','Text','Start Game','Position',[45,156,150,34],'ButtonPushedFcn',@startGame);
helpButton=uibutton(panel,'push','Text','Help','Position',[45,41,150,34],'ButtonPushedFcn',@showHelp);
difficultyDropDown=uidropdown(panel,'Items',{'easy','Medium','Hard'},'Position',[45,100,150,30],'ValueChangedFcn',@changeDifficulty);
scoreLabel=uilabel(fig,'Text','mark','Position',[327,300,87,60],'FontSize',36,'FontWeight','bold');
scoreField=uieditfield(fig,'numeric','Position',[410,300,160,60],'FontSize',36,'Enable','off');

%初始化游戏参数
gameArea=zeros(20,10);
gameAreaColors=repmat({[1,1,1]},size(gameArea));
shapes=initializeShapes();
colors=initializeColors();
flag=0;
score=0;
gameTimer=timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',@tetrisGame);

%创建游戏区域和提示区域
textArea1=createTextArea(fig,20,10,[45,30,240,480]);
textArea2=createTextArea(fig,5,10,[330,385,240,125]);

%设置键盘事件处理函数
fig.WindowKeyPressFcn=@keyPress;


%开始游戏模块
    function startGame(~,~)
        scoreField.Value=0;
        generateNewBlock();
        start(gameTimer);
        startButton.Enable='off';
        difficultyDropDown.Enable='off';
        helpButton.Enable='off';
    end

%游戏帮助模块
    function showHelp(~,~)
        msg={'游戏玩法说明:',...
            '使用左右键移动方块，上键旋转方块，下键加速方块下落。',...
            '',...
            '分数规则:',...
            '每消除一行，得10分。难度越高，分数增加越快。',...
            '',...
            '控制难度:',...
            '在控制面板中选择游戏难度。'};
        uialert(fig,msg,'游戏帮助','Icon','question','Interpreter','html');

    end

%游戏难度选择模块
    function changeDifficulty(~,~)
        value=difficultyDropDown.Value;
        switch value
            case 'easy'
                gameTimer.Period=1;
            case 'Medium'
                gameTimer.Period=0.8;
            case 'Hard'
                gameTimer.Period=0.5;
            otherwise
                gameTimer.Period=1;
        end
    end

%键盘事件模块(捕捉移动指令)
    function keyPress(~,event)
        key=event.Key;
        if flag==0
            return
        end
        stop(gameTimer);
        moveBlock(key);
        start(gameTimer);
    end

%游戏主体模块
    function tetrisGame(~,~)
        %假设方块将要下移一行
        newBlockId=blockId-[1,0;1,0;1,0;1,0];

        %检查是否到达底部或有障碍物
        if any(newBlockId(:,1)<1) || any(newBlockId(:,1)>20) || any(gameArea(sub2ind(size(gameArea),newBlockId(:,1),newBlockId(:,2)))==1)
            %将方块固定在当前位置
            for i=1:4
                row=blockId(i,1);
                col=blockId(i,2);
                gameArea(row,col)=1;%更新游戏区域
                gameAreaColors{row,col}=color;%更新游戏区域颜色
            end

            %检查是否有任何一列完全被填满
            if any(gameArea(20,:)==1)
                %游戏失败
                gameOver();
                return;
            end

            %检查并消除完整的行
            checkCompleteRows();
            %这里添加产生新方块的代码
            generateNewBlock();
        else
            %清除当前方块的颜色
            for i=1:4
                row=blockId(i,1);
                col=blockId(i,2);
                textArea1{row,col}.BackgroundColor=[1,1,1];
            end

            %更新方块位置
            blockId=newBlockId;

            %绘制新位置的方块
            for i=1:4
                row=blockId(i,1);
                col=blockId(i,2);
                textArea1{row,col}.BackgroundColor=color;
            end
        end
    end


%新方块创造模块
    function generateNewBlock()
        global shapeId block;
        if flag==0
            shapeId=randi([1,7]);
            shape=shapes{shapeId};
            flag=1;
            color=colors(randi([1,7]),:);
            blockId=positionStart(shape,shapeId);
            block=newBlock();
        else
            shape=block{1};
            blockId=block{3};
            color=block{2};
            block=newBlock();
        end
        for i=1:4
            row=blockId(i,1);
            col=blockId(i,2);
            textArea1{row,col}.BackgroundColor=color;
        end
    end

%方块移动模块
    function moveBlock(key)
        distance=blockId-shape;
        if any(fix(distance(:,1))~=distance(:,1))&&any(fix(distance(:,2))==distance(:,2))%检查是否有小数部分
            distance(:,1)=distance(:,1)-0.5;
            distance(:,2)=distance(:,2)+0.5;
        elseif any(fix(distance(:,2))~=distance(:,2))&&any(fix(distance(:,1))==distance(:,1))%检查是否有小数部分
            distance(:,1)=distance(:,1)+0.5;
            distance(:,2)=distance(:,2)-0.5;
        end
        switch key
            case 'rightarrow'
                newBlockId=blockId+[0,1;0,1;0,1;0,1];
            case 'leftarrow'
                newBlockId=blockId-[0,1;0,1;0,1;0,1];
            case 'downarrow'
                newBlockId=blockId-[1,0;1,0;1,0;1,0];
            case 'uparrow'
                blockDirection();
                newBlockId=shape+distance;
        end
        %边界检查逻辑
        if any(newBlockId(:,2)<1) || any(newBlockId(:,2)>10) || ...
                any(newBlockId(:,1)<1) || any(newBlockId(:,1)>20) || ...
                any(gameArea(sub2ind(size(gameArea),newBlockId(:,1),newBlockId(:,2)))==1)
            return;%如果移动后超出边界或与其他方块重叠，则不执行移动
        end
        for i=1:4
            row=blockId(i,1);
            col=blockId(i,2);
            textArea1{row,col}.BackgroundColor=[1,1,1];%修改颜色
        end
        blockId=newBlockId;
        for i=1:4
            row=blockId(i,1);
            col=blockId(i,2);
            textArea1{row,col}.BackgroundColor=color;%修改颜色
        end
    end

%基础方块属性模块
    function shapes=initializeShapes()
        shapes=cell(1,7);
        shapes{1}=[0,0;0,1;1,0;1,1];%O型
        shapes{2}=[-0.5,0;0.5,0;0.5,1;1.5,1];%S型
        shapes{3}=[-0.5,1;0.5,1;0.5,0;1.5,0];%Z型
        shapes{4}=[2,0.5;1,0.5;0,0.5;-1,0.5];%I型
        shapes{5}=[0.5,1.5;0.5,0.5;0.5,-0.5;1.5,-0.5];%L型
        shapes{6}=[0.5,-0.5;0.5,0.5;0.5,1.5;1.5,1.5];%J型
        shapes{7}=[0.5,1.5;0.5,0.5;1.5,0.5;0.5,-0.5];%T型
    end

%方块颜色模块
    function colors=initializeColors()
        colors=[1,0,0;%红色
            1,0.647,0;%橙色
            1,1,0;%黄色
            0,1,0;%绿色
            0,0,1;%蓝色
            0.502,0,0.502;%紫色
            1,0.753,0.796];%粉红色
    end

%游戏区域创建模块
    function textArea=createTextArea(parent,rows,cols,position)
        %figure(fig)
        textArea=cell(rows,cols);
        for row=1:rows
            for col=1:cols
                textArea{row,col}=uitextarea(parent,...
                    'Editable','off',...
                    'Position',[(col-1)*23+position(1),position(2)+position(4)-row*23,23,23],...
                    'BackgroundColor',[1,1,1]);
            end
        end
    end

%提示区域模块
    function block=newBlock()
        newShapeId=randi([1,7]);
        newShape1=shapes{newShapeId};
        newColor=colors(randi([1,7]),:);
        newShape=positionStart(newShape1,newShapeId);
        %清空提示区域
        for row=1:5
            for col=1:10
                textArea2{row,col}.BackgroundColor=[1,1,1];
            end
        end

        %在提示区域显示下一个方块
        for i=1:size(newShape,1)
            row=newShape(i,1)-16;
            col=newShape(i,2);
            textArea2{row,col}.BackgroundColor=newColor;
        end
        block={newShape1,newColor,newShape};
    end

%方块位置模块
    function position=positionStart(shape,shapeId)
        position=shape;
        switch shapeId
            case 1
                position=shape+[19,5;19,5;19,5;19,5];
            case 2
                position=shape+[18.5,5;18.5,5;18.5,5;18.5,5];
            case 3
                position=shape+[18.5,5;18.5,5;18.5,5;18.5,5];
            case 4
                position=shape+[18,5.5;18,5.5;18,5.5;18,5.5];
            case 5
                position=shape+[18.5,5.5;18.5,5.5;18.5,5.5;18.5,5.5];
            case 6
                position=shape+[18.5,5.5;18.5,5.5;18.5,5.5;18.5,5.5];
            case 7
                position=shape+[18.5,5.5;18.5,5.5;18.5,5.5;18.5,5.5];
        end
    end

%方块旋转模块
    function blockDirection()
        A=[0,1;-1,0];
        B=[1,0;1,0;1,0;1,0];
        shape=shape*A+B;
    end

%方块清除模块
    function checkCompleteRows()
        completedRows=[];
        for row=1:size(gameArea,1)
            if all(gameArea(row,:)==1)
                completedRows=[completedRows,row];
            end
        end

        %如果存在完成的行，同时闪烁这些行
        if ~isempty(completedRows)
            blinkRow(completedRows);
        end

        %然后一次性消除这些行
        for i=length(completedRows):-1:1
            eliminateRow(completedRows(i));
            scoreField.Value=scoreField.Value+80/gameTimer.Period;
        end
    end

%方块清除后移动模块
    function eliminateRow(row)
        %消除指定行
        gameArea(row,:)=0;

        %下移上方的所有行
        for r=row+1:20
            gameArea(r-1,:)=gameArea(r,:);
            gameAreaColors(r-1,:)=gameAreaColors(r,:);
        end

        %将顶部行设置为0
        gameArea(20,:)=0;
        gameAreaColors(20,:)={[1,1,1]};

        %更新显示
        updateDisplay();
    end

%方块显示模块
    function updateDisplay()
        %遍历游戏区域的每个单元格
        for row=1:size(gameArea,1)
            for col=1:size(gameArea,2)
                if gameArea(row,col)==1
                    %如果单元格被占用，则显示对应的颜色
                    textArea1{row,col}.BackgroundColor=gameAreaColors{row,col};
                else
                    %如果单元格空闲，则显示为白色
                    textArea1{row,col}.BackgroundColor=[1,1,1];
                end
            end
        end
    end

%清除时闪烁模块
    function blinkRow(rows)
        %设置闪烁次数和持续时间
        numBlinks=3;
        blinkDuration=0.3;%秒

        %循环闪烁
        for i=1:numBlinks
            %将行颜色设置为不同颜色（例如，黑色）
            for r=rows
                setRowColor(r,[0,0,0]);
            end
            pause(blinkDuration);

            %恢复原来的颜色
            for r=rows
                setRowColor(r,[1,1,1]);
            end
            pause(blinkDuration);
        end
    end


%背景颜色模快
    function setRowColor(row,color)
        for col=1:10
            textArea1{row,col}.BackgroundColor=color;
        end
    end

%游戏结束模块
    function gameOver()
        %停止游戏计时器
        stop(gameTimer);
        delete(gameTimer);

        %初始化游戏参数
        gameAreaColors=repmat({[1,1,1]},size(gameArea));
        gameArea=zeros(20,10);
        flag=0;
        difficultyDropDown.Enable='on';
        for row=1:20
            for col=1:10
                textArea1{row,col}.BackgroundColor=[1,1,1];%修改颜色
            end
        end

        %显示游戏结束消息
        msg='游戏结束';
        title='游戏结束';
        selection=uiconfirm(fig,msg,title,...
            'Options',{'重新开始','返回主界面','退出游戏'},...
            'DefaultOption',1,'CancelOption',2);
        switch selection
            case '重新开始'
                scoreField.Value=0;
                difficultyDropDown.Enable="off";
                flag=1;
                gameTimer=timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',@tetrisGame);
                start(gameTimer);
                fig.Focus;
            case '返回主界面'
                gameTimer=timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',@tetrisGame);
                startButton.Enable="on";
                difficultyDropDown.Enable='on';
                helpButton.Enable="on";
            case '退出游戏'
                delete(fig);
        end
    end
end
