function ChineseChess()
% 中国象棋 - MATLAB GUI 游戏
% 双人对弈，红方先行
% 点击己方棋子选中，再点击目标位置移动

    %% 初始化棋盘数据
    % 棋盘 10行 x 9列 (行1-10, 列1-9)
    % 红方在下方(行8-10), 黑方在上方(行1-3)
    % 棋子编码: 正数=红方, 负数=黑方
    % 1=帅/将, 2=仕/士, 3=相/象, 4=马, 5=车, 6=炮, 7=兵/卒

    board = zeros(10, 9);

    % 黑方 (上方)
    board(1,1) = -5; board(1,2) = -4; board(1,3) = -3; board(1,4) = -2; board(1,5) = -1;
    board(1,6) = -2; board(1,7) = -3; board(1,8) = -4; board(1,9) = -5;
    board(3,2) = -6; board(3,8) = -6;
    board(4,1) = -7; board(4,3) = -7; board(4,5) = -7; board(4,7) = -7; board(4,9) = -7;

    % 红方 (下方)
    board(10,1) = 5; board(10,2) = 4; board(10,3) = 3; board(10,4) = 2; board(10,5) = 1;
    board(10,6) = 2; board(10,7) = 3; board(10,8) = 4; board(10,9) = 5;
    board(8,2) = 6; board(8,8) = 6;
    board(7,1) = 7; board(7,3) = 7; board(7,5) = 7; board(7,7) = 7; board(7,9) = 7;

    %% 棋子名称映射
    pieceNames = containers.Map(...
        {1,2,3,4,5,6,7,-1,-2,-3,-4,-5,-6,-7}, ...
        {'帅','仕','相','马','车','炮','兵','将','士','象','马','车','炮','卒'});

    %% 创建GUI
    fig = figure('Name', '中国象棋', 'NumberTitle', 'off', ...
        'Position', [200, 50, 700, 800], 'Color', [0.95 0.9 0.8], ...
        'MenuBar', 'none', 'ToolBar', 'none', ...
        'CloseRequestFcn', @closeGame, ...
        'Resize', 'off');

    ax = axes('Parent', fig, 'Position', [0.05 0.08 0.9 0.85]);
    axis equal; axis off; hold on;
    xlim([0 10]); ylim([0 11]);

    % 游戏状态
    selectedPos = [];       % 当前选中的棋子位置 [row, col]
    currentPlayer = 1;      % 1=红方, -1=黑方
    gameOver = false;
    moveHistory = {};       % 移动历史

    % 状态文本
    statusText = uicontrol('Parent', fig, 'Style', 'text', ...
        'String', '红方走棋', 'FontSize', 16, 'FontWeight', 'bold', ...
        'ForegroundColor', 'r', 'BackgroundColor', [0.95 0.9 0.8], ...
        'Position', [100 10 500 40], 'HorizontalAlignment', 'center');

    % 重新开始按钮
    uicontrol('Parent', fig, 'Style', 'pushbutton', ...
        'String', '重新开始', 'FontSize', 12, ...
        'Position', [280 55 140 35], ...
        'Callback', @restartGame);

    % 绘制初始棋盘
    drawBoard();
    drawPieces();

    % 设置鼠标点击回调
    set(fig, 'WindowButtonDownFcn', @onClick);

    %% ========== 绘制棋盘 ==========
    function drawBoard()
        cla(ax);
        % 背景色
        rectangle('Position', [0.3 0.3 9.4 10.4], 'FaceColor', [0.96 0.87 0.70], ...
            'EdgeColor', 'none');

        % 画横线 (10条)
        for r = 1:10
            line([1 9], [r r], 'Color', [0.1 0.1 0.1], 'LineWidth', 1.5);
        end

        % 画竖线
        for c = 1:9
            % 上半部分
            line([c c], [1 5], 'Color', [0.1 0.1 0.1], 'LineWidth', 1.5);
            % 下半部分
            line([c c], [6 10], 'Color', [0.1 0.1 0.1], 'LineWidth', 1.5);
        end

        % 左右边框竖线 (贯穿)
        line([1 1], [1 10], 'Color', [0.1 0.1 0.1], 'LineWidth', 2);
        line([9 9], [1 10], 'Color', [0.1 0.1 0.1], 'LineWidth', 2);

        % 楚河汉界
        text(3, 5.5, '楚 河', 'FontSize', 22, 'FontWeight', 'bold', ...
            'Color', [0.1 0.1 0.1], 'HorizontalAlignment', 'center');
        text(7, 5.5, '汉 界', 'FontSize', 22, 'FontWeight', 'bold', ...
            'Color', [0.1 0.1 0.1], 'HorizontalAlignment', 'center');

        % 九宫格对角线 (黑方)
        line([4 6], [1 3], 'Color', [0.1 0.1 0.1], 'LineWidth', 1.2);
        line([4 6], [3 1], 'Color', [0.1 0.1 0.1], 'LineWidth', 1.2);

        % 九宫格对角线 (红方)
        line([4 6], [8 10], 'Color', [0.1 0.1 0.1], 'LineWidth', 1.2);
        line([4 6], [10 8], 'Color', [0.1 0.1 0.1], 'LineWidth', 1.2);

        % 炮位标记
        drawCrossMark(2, 3); drawCrossMark(2, 7);
        drawCrossMark(8, 3); drawCrossMark(8, 7);

        % 兵/卒位标记
        drawCrossMark(4, 1); drawCrossMark(4, 3); drawCrossMark(4, 5);
        drawCrossMark(4, 7); drawCrossMark(4, 9);
        drawCrossMark(7, 1); drawCrossMark(7, 3); drawCrossMark(7, 5);
        drawCrossMark(7, 7); drawCrossMark(7, 9);
    end

    function drawCrossMark(r, c)
        d = 0.15; g = 0.08;
        % 上方
        if r < 10
            line([c-g c-g], [r+d r+d+g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
            line([c-g c+g], [r+d+g r+d+g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
            line([c+g c+g], [r+d r+d+g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
        end
        % 下方
        if r > 1
            line([c-g c-g], [r-d r-d-g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
            line([c-g c+g], [r-d-g r-d-g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
            line([c+g c+g], [r-d r-d-g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
        end
        % 左方
        if c > 1
            line([c-d c-d-g], [r+g r+g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
            line([c-d-g c-d-g], [r-g r+g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
            line([c-d c-d-g], [r-g r-g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
        end
        % 右方
        if c < 9
            line([c+d c+d+g], [r+g r+g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
            line([c+d+g c+d+g], [r-g r+g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
            line([c+d c+d+g], [r-g r-g], 'Color', [0.1 0.1 0.1], 'LineWidth', 1);
        end
    end

    %% ========== 绘制棋子 ==========
    function drawPieces()
        % 清除之前的棋子绘制(保留棋盘线)
        delete(findobj(ax, 'Tag', 'piece'));
        delete(findobj(ax, 'Tag', 'selectMark'));

        for r = 1:10
            for c = 1:9
                p = board(r, c);
                if p ~= 0
                    drawOnePiece(r, c, p);
                end
            end
        end

        % 高亮选中的棋子
        if ~isempty(selectedPos)
            r = selectedPos(1); c = selectedPos(2);
            rectangle('Position', [c-0.45 r-0.45 0.9 0.9], ...
                'Curvature', [1 1], 'EdgeColor', [0 1 0], ...
                'LineWidth', 3, 'Tag', 'selectMark');
        end
    end

    function drawOnePiece(r, c, p)
        % 棋子圆形背景
        if p > 0
            bgColor = [1 0.95 0.85];   % 红方底色
            textColor = [0.8 0 0];      % 红色字
            edgeColor = [0.6 0 0];
        else
            bgColor = [1 0.95 0.85];   % 黑方底色
            textColor = [0 0 0];        % 黑色字
            edgeColor = [0 0 0];
        end

        rectangle('Position', [c-0.42 r-0.42 0.84 0.84], ...
            'Curvature', [1 1], 'FaceColor', bgColor, ...
            'EdgeColor', edgeColor, 'LineWidth', 2, 'Tag', 'piece');

        % 棋子文字
        name = pieceNames(abs(p));
        % 红方用宋体风格，黑方用楷体风格
        if p > 0
            text(c, r, name, 'FontSize', 20, 'FontWeight', 'bold', ...
                'Color', textColor, 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'FontName', 'SimHei', ...
                'Tag', 'piece');
        else
            text(c, r, name, 'FontSize', 20, 'FontWeight', 'bold', ...
                'Color', textColor, 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'FontName', 'SimHei', ...
                'Tag', 'piece');
        end
    end

    %% ========== 鼠标点击处理 ==========
    function onClick(~, ~)
        if gameOver; return; end

        pt = get(ax, 'CurrentPoint');
        col = round(pt(1,1));
        row = round(pt(1,2));

        if col < 1 || col > 9 || row < 1 || row > 10
            return;
        end

        clickedPiece = board(row, col);

        if isempty(selectedPos)
            % 没有选中棋子 -> 选择己方棋子
            if clickedPiece ~= 0 && sign(clickedPiece) == currentPlayer
                selectedPos = [row, col];
                drawPieces();
            end
        else
            % 已有选中棋子
            sr = selectedPos(1); sc = selectedPos(2);

            if row == sr && col == sc
                % 取消选择
                selectedPos = [];
                drawPieces();
                return;
            end

            % 如果点击的是己方棋子，切换选择
            if clickedPiece ~= 0 && sign(clickedPiece) == currentPlayer
                selectedPos = [row, col];
                drawPieces();
                return;
            end

            % 尝试移动
            if isValidMove(sr, sc, row, col)
                % 执行移动
                captured = board(row, col);
                board(row, col) = board(sr, sc);
                board(sr, sc) = 0;

                % 检查移动后是否被将军（自杀移动不允许）
                if isInCheck(currentPlayer)
                    % 撤销移动
                    board(sr, sc) = board(row, col);
                    board(row, col) = captured;
                    setStatus('此移动会导致被将军！', [1 0.5 0]);
                    selectedPos = [];
                    drawPieces();
                    return;
                end

                % 检查飞将（两个将帅不能面对面）
                if isKingsFacing()
                    % 撤销移动
                    board(sr, sc) = board(row, col);
                    board(row, col) = captured;
                    setStatus('不能让将帅面对面！', [1 0.5 0]);
                    selectedPos = [];
                    drawPieces();
                    return;
                end

                % 记录移动
                moveHistory{end+1} = struct('from', [sr sc], 'to', [row col], ...
                    'piece', board(row,col), 'captured', captured);

                selectedPos = [];

                % 检查是否吃掉了对方的将/帅
                if abs(captured) == 1
                    drawBoard();
                    drawPieces();
                    gameOver = true;
                    if currentPlayer == 1
                        setStatus('红方胜！', [1 0 0]);
                    else
                        setStatus('黑方胜！', [0 0 0]);
                    end
                    return;
                end

                % 切换玩家
                currentPlayer = -currentPlayer;

                % 检查对方是否被将杀
                if isCheckmate(currentPlayer)
                    drawBoard();
                    drawPieces();
                    gameOver = true;
                    if currentPlayer == 1
                        setStatus('黑方胜！将杀红方！', [0 0 0]);
                    else
                        setStatus('红方胜！将杀黑方！', [1 0 0]);
                    end
                    return;
                end

                % 检查对方是否被将军
                if isInCheck(currentPlayer)
                    if currentPlayer == 1
                        setStatus('红方被将军！', [1 0 0]);
                    else
                        setStatus('黑方被将军！', [0 0 0]);
                    end
                else
                    if currentPlayer == 1
                        setStatus('红方走棋', [1 0 0]);
                    else
                        setStatus('黑方走棋', [0 0 0]);
                    end
                end

                drawBoard();
                drawPieces();
            else
                setStatus('无效移动！', [1 0.5 0]);
            end
        end
    end

    %% ========== 移动规则验证 ==========
    function valid = isValidMove(sr, sc, tr, tc)
        valid = false;
        piece = board(sr, sc);
        pType = abs(piece);
        isRed = piece > 0;

        % 不能吃己方棋子
        if board(tr, tc) ~= 0 && sign(board(tr, tc)) == sign(piece)
            return;
        end

        switch pType
            case 1  % 帅/将
                valid = isValidKingMove(sr, sc, tr, tc, isRed);
            case 2  % 仕/士
                valid = isValidAdvisorMove(sr, sc, tr, tc, isRed);
            case 3  % 相/象
                valid = isValidBishopMove(sr, sc, tr, tc, isRed);
            case 4  % 马
                valid = isValidKnightMove(sr, sc, tr, tc);
            case 5  % 车
                valid = isValidRookMove(sr, sc, tr, tc);
            case 6  % 炮
                valid = isValidCannonMove(sr, sc, tr, tc);
            case 7  % 兵/卒
                valid = isValidPawnMove(sr, sc, tr, tc, isRed);
        end
    end

    function valid = isValidKingMove(sr, sc, tr, tc, isRed)
        valid = false;
        % 帅/将只能在九宫格内移动，每次一格（横或竖）
        if isRed
            if tr < 8 || tr > 10 || tc < 4 || tc > 6; return; end
        else
            if tr < 1 || tr > 3 || tc < 4 || tc > 6; return; end
        end

        dr = abs(tr - sr);
        dc = abs(tc - sc);

        % 普通移动：一格
        if (dr == 1 && dc == 0) || (dr == 0 && dc == 1)
            valid = true;
            return;
        end

        % 飞将（对面帅将直接对视时可以吃对方）
        if dc == 0 && dr > 1
            % 检查是否是对面的将/帅
            target = board(tr, tc);
            if abs(target) == 1 && sign(target) ~= isRed
                % 检查中间是否有棋子阻挡
                minR = min(sr, tr); maxR = max(sr, tr);
                blocked = false;
                for r = minR+1:maxR-1
                    if board(r, sc) ~= 0
                        blocked = true;
                        break;
                    end
                end
                if ~blocked
                    valid = true;
                end
            end
        end
    end

    function valid = isValidAdvisorMove(sr, sc, tr, tc, isRed)
        valid = false;
        % 仕/士只能在九宫格内，沿对角线移动一格
        if isRed
            if tr < 8 || tr > 10 || tc < 4 || tc > 6; return; end
        else
            if tr < 1 || tr > 3 || tc < 4 || tc > 6; return; end
        end

        if abs(tr - sr) == 1 && abs(tc - sc) == 1
            valid = true;
        end
    end

    function valid = isValidBishopMove(sr, sc, tr, tc, isRed)
        valid = false;
        % 相/象走田字，不能过河，有塞眼规则
        if isRed && tr < 6; return; end
        if ~isRed && tr > 5; return; end

        dr = abs(tr - sr);
        dc = abs(tc - sc);

        if dr == 2 && dc == 2
            % 检查塞眼（田字中心）
            eyeR = (sr + tr) / 2;
            eyeC = (sc + tc) / 2;
            if board(eyeR, eyeC) == 0
                valid = true;
            end
        end
    end

    function valid = isValidKnightMove(sr, sc, tr, tc)
        valid = false;
        dr = abs(tr - sr);
        dc = abs(tc - sc);

        % 马走日字
        if (dr == 2 && dc == 1) || (dr == 1 && dc == 2)
            % 检查蹩马腿
            if dr == 2
                % 竖向走两格，检查中间横格
                blockR = (sr + tr) / 2;
                if board(blockR, sc) ~= 0
                    return;
                end
            else
                % 横向走两格，检查中间竖格
                blockC = (sc + tc) / 2;
                if board(sr, blockC) ~= 0
                    return;
                end
            end
            valid = true;
        end
    end

    function valid = isValidRookMove(sr, sc, tr, tc)
        valid = false;
        % 车走直线
        if sr ~= tr && sc ~= tc; return; end

        % 检查路径上是否有棋子
        if sr == tr
            minC = min(sc, tc); maxC = max(sc, tc);
            for c = minC+1:maxC-1
                if board(sr, c) ~= 0; return; end
            end
        else
            minR = min(sr, tr); maxR = max(sr, tr);
            for r = minR+1:maxR-1
                if board(r, sc) ~= 0; return; end
            end
        end
        valid = true;
    end

    function valid = isValidCannonMove(sr, sc, tr, tc)
        valid = false;
        % 炮走直线，吃子需要翻山（一个炮架）
        if sr ~= tr && sc ~= tc; return; end

        % 计算路径上的棋子数
        count = 0;
        if sr == tr
            minC = min(sc, tc); maxC = max(sc, tc);
            for c = minC+1:maxC-1
                if board(sr, c) ~= 0; count = count + 1; end
            end
        else
            minR = min(sr, tr); maxR = max(sr, tr);
            for r = minR+1:maxR-1
                if board(r, sc) ~= 0; count = count + 1; end
            end
        end

        target = board(tr, tc);
        if target == 0
            % 不吃子，路径上不能有棋子
            valid = (count == 0);
        else
            % 吃子，必须恰好隔一个棋子
            valid = (count == 1);
        end
    end

    function valid = isValidPawnMove(sr, sc, tr, tc, isRed)
        valid = false;
        dr = tr - sr;
        dc = abs(tc - sc);

        if isRed
            % 红方兵：未过河前只能前进（行号减小），过河后可左右
            if sr >= 6
                % 未过河：只能前进一格
                if dr == -1 && dc == 0
                    valid = true;
                end
            else
                % 已过河：前进或左右一格，不能后退
                if (dr == -1 && dc == 0) || (dr == 0 && dc == 1)
                    valid = true;
                end
            end
        else
            % 黑方卒：未过河前只能前进（行号增大），过河后可左右
            if sr <= 5
                % 未过河：只能前进一格
                if dr == 1 && dc == 0
                    valid = true;
                end
            else
                % 已过河：前进或左右一格，不能后退
                if (dr == 1 && dc == 0) || (dr == 0 && dc == 1)
                    valid = true;
                end
            end
        end
    end

    %% ========== 将军检测 ==========
    function check = isInCheck(playerSide)
        % 检查 playerSide 的将/帅是否被对方攻击
        check = false;

        % 找到己方将/帅的位置
        kingPos = [];
        for r = 1:10
            for c = 1:9
                if board(r,c) == playerSide * 1
                    kingPos = [r, c];
                    break;
                end
            end
            if ~isempty(kingPos); break; end
        end

        if isempty(kingPos); return; end

        kr = kingPos(1); kc = kingPos(2);

        % 检查对方每个棋子是否能攻击到将/帅
        for r = 1:10
            for c = 1:9
                if board(r,c) ~= 0 && sign(board(r,c)) ~= playerSide
                    % 临时保存
                    origTarget = board(kr, kc);
                    if canAttack(r, c, kr, kc)
                        check = true;
                        return;
                    end
                end
            end
        end
    end

    function can = canAttack(sr, sc, tr, tc)
        % 判断 sr,sc 的棋子是否能攻击到 tr,tc（简化版isValidMove）
        piece = board(sr, sc);
        pType = abs(piece);
        isRed = piece > 0;
        can = false;

        switch pType
            case 1  % 将/帅
                dr = abs(tr - sr); dc = abs(tc - sc);
                if (dr == 1 && dc == 0) || (dr == 0 && dc == 1)
                    % 在九宫格内
                    if isRed
                        if tr >= 8 && tr <= 10 && tc >= 4 && tc <= 6
                            can = true;
                        end
                    else
                        if tr >= 1 && tr <= 3 && tc >= 4 && tc <= 6
                            can = true;
                        end
                    end
                end
            case 2  % 仕/士
                dr = abs(tr - sr); dc = abs(tc - sc);
                if dr == 1 && dc == 1
                    if isRed
                        if tr >= 8 && tr <= 10 && tc >= 4 && tc <= 6
                            can = true;
                        end
                    else
                        if tr >= 1 && tr <= 3 && tc >= 4 && tc <= 6
                            can = true;
                        end
                    end
                end
            case 3  % 相/象
                dr = abs(tr - sr); dc = abs(tc - sc);
                if dr == 2 && dc == 2
                    eyeR = (sr + tr) / 2; eyeC = (sc + tc) / 2;
                    if board(eyeR, eyeC) == 0
                        if (isRed && tr >= 6) || (~isRed && tr <= 5)
                            can = true;
                        end
                    end
                end
            case 4  % 马
                dr = abs(tr - sr); dc = abs(tc - sc);
                if (dr == 2 && dc == 1) || (dr == 1 && dc == 2)
                    blocked = false;
                    if dr == 2
                        blockR = (sr + tr) / 2;
                        if board(blockR, sc) ~= 0; blocked = true; end
                    else
                        blockC = (sc + tc) / 2;
                        if board(sr, blockC) ~= 0; blocked = true; end
                    end
                    if ~blocked; can = true; end
                end
            case 5  % 车
                if sr == tr || sc == tc
                    blocked = false;
                    if sr == tr
                        minC = min(sc,tc); maxC = max(sc,tc);
                        for cc = minC+1:maxC-1
                            if board(sr,cc) ~= 0; blocked = true; break; end
                        end
                    else
                        minR = min(sr,tr); maxR = max(sr,tr);
                        for rr = minR+1:maxR-1
                            if board(rr,sc) ~= 0; blocked = true; break; end
                        end
                    end
                    if ~blocked; can = true; end
                end
            case 6  % 炮
                if sr == tr || sc == tc
                    count = 0;
                    if sr == tr
                        minC = min(sc,tc); maxC = max(sc,tc);
                        for cc = minC+1:maxC-1
                            if board(sr,cc) ~= 0; count = count+1; end
                        end
                    else
                        minR = min(sr,tr); maxR = max(sr,tr);
                        for rr = minR+1:maxR-1
                            if board(rr,sc) ~= 0; count = count+1; end
                        end
                    end
                    if count == 1; can = true; end
                end
            case 7  % 兵/卒
                dr = tr - sr; dc = abs(tc - sc);
                if isRed
                    if (dr == -1 && dc == 0) || (sr <= 5 && dr == 0 && dc == 1)
                        can = true;
                    end
                else
                    if (dr == 1 && dc == 0) || (sr >= 6 && dr == 0 && dc == 1)
                        can = true;
                    end
                end
        end
    end

    %% ========== 将杀检测 ==========
    function mate = isCheckmate(playerSide)
        % 检查 playerSide 是否被将杀（无合法移动可解除将军）
        mate = false;

        if ~isInCheck(playerSide)
            return; % 没被将军，不是将杀
        end

        % 尝试所有己方棋子的所有可能移动
        for r = 1:10
            for c = 1:9
                if board(r,c) ~= 0 && sign(board(r,c)) == playerSide
                    % 尝试移动到每个位置
                    for tr = 1:10
                        for tc = 1:9
                            if isValidMove(r, c, tr, tc)
                                % 尝试移动
                                origFrom = board(r, c);
                                origTo = board(tr, tc);
                                board(tr, tc) = board(r, c);
                                board(r, c) = 0;

                                stillInCheck = isInCheck(playerSide);
                                kingsFacing = isKingsFacing();

                                % 撤销
                                board(r, c) = origFrom;
                                board(tr, tc) = origTo;

                                if ~stillInCheck && ~kingsFacing
                                    return; % 有合法移动，不是将杀
                                end
                            end
                        end
                    end
                end
            end
        end

        mate = true; % 没有合法移动，将杀
    end

    %% ========== 飞将检测 ==========
    function facing = isKingsFacing()
        % 检查两个将帅是否在同一列且中间无棋子
        facing = false;
        redKingPos = []; blackKingPos = [];
        for r = 1:10
            for c = 1:9
                if board(r,c) == 1
                    redKingPos = [r, c];
                elseif board(r,c) == -1
                    blackKingPos = [r, c];
                end
            end
        end
        if isempty(redKingPos) || isempty(blackKingPos); return; end
        if redKingPos(2) ~= blackKingPos(2); return; end
        % 同一列，检查中间是否有棋子
        c = redKingPos(2);
        minR = min(redKingPos(1), blackKingPos(1));
        maxR = max(redKingPos(1), blackKingPos(1));
        for r = minR+1:maxR-1
            if board(r, c) ~= 0
                return; % 有棋子阻挡，不违反飞将规则
            end
        end
        facing = true;
    end

    %% ========== 工具函数 ==========
    function setStatus(msg, color)
        set(statusText, 'String', msg, 'ForegroundColor', color);
    end

    function restartGame(~, ~)
        board = zeros(10, 9);
        board(1,1) = -5; board(1,2) = -4; board(1,3) = -3; board(1,4) = -2; board(1,5) = -1;
        board(1,6) = -2; board(1,7) = -3; board(1,8) = -4; board(1,9) = -5;
        board(3,2) = -6; board(3,8) = -6;
        board(4,1) = -7; board(4,3) = -7; board(4,5) = -7; board(4,7) = -7; board(4,9) = -7;
        board(10,1) = 5; board(10,2) = 4; board(10,3) = 3; board(10,4) = 2; board(10,5) = 1;
        board(10,6) = 2; board(10,7) = 3; board(10,8) = 4; board(10,9) = 5;
        board(8,2) = 6; board(8,8) = 6;
        board(7,1) = 7; board(7,3) = 7; board(7,5) = 7; board(7,7) = 7; board(7,9) = 7;

        selectedPos = [];
        currentPlayer = 1;
        gameOver = false;
        moveHistory = {};

        drawBoard();
        drawPieces();
        setStatus('红方走棋', [1 0 0]);
    end

    function closeGame(~, ~)
        delete(fig);
    end

end
