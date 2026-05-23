
fig=uifigure('Name','tetris','Position',[500,500,640,550]);
textArea1=createTextArea(fig,20,10,[45,30,240,480]);
textArea2=createTextArea(fig,5,10,[330,385,240,125]);

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