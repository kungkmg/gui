local Genv = (getgenv or function() return _G end)();

local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");
local Player = Players.LocalPlayer;
local Mouse = Player:GetMouse();

local Form = string.format;

local GuiClosed = false;
local Signals = {};

local Coroutine = function(Function)coroutine.resume(coroutine.create(Function)) end;
local Request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request or function(Link)
    return {
        Body = Link.Method == "GET" and game:HttpGet(Link.Url, true) or "404: Not Found",
        Headers = {},
        StatusCode = Link.Method == "GET" and 200 or 404,
    };
end;

local GetAsset = (getsynasset or getcustomasset) or function(Location) return Form("rbxasset://%s", Location) end;

local function Or(Variable, Checks)
    for Int, Value in pairs(Checks) do
        if Variable == Value then
            return true;
        end;
    end;
    return false;
end;
local function RemoveExtraSpaces(String)
    while string.find(String, "  ") ~= nil do
        String = string.gsub(String, "  ", " ");
    end;
    return String;
end;
local function Token(Layout, Library)
    local Token = "";
    local Library = string.split(Library or "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", "");
    for Int, String in pairs(string.split(Layout, "")) do
        if String == "#" then
            String = Library[math.random(1, #Library)];
        end;
        Token = Token .. String;
    end;
    return Token;
end;
local function GetExploit()
    return
    (syn and is_sirhurt_closure == nil and pebcexecute == nil and "Synapse X") or
        (pebcexecute and "ProtoSmasher") or
        (OXYGEN_LOADED and "Oxygen") or
        (WrapGlobal and "WeAreDevs") or
        (getscriptenvs and "Calimari") or
        (unit and syn == nil and "Unit") or
        (shadow_env and "Shadow") or
        (KRNL_LOADED and "Krnl") or
        (secure_load and "Sirhut") or
        (jit and "EasyExploits") or
        (isvm and "Proxo") or
        (isElectron and "Electron") or "Unknown";
end;
local function SearchTableBy(Operation, Table, Value)
    local Loop = nil;
    Loop = function(Input)
        for Index, Found in pairs(Input) do
            if Operation == "Value" then
                if typeof(Found) == "table" then
                    return Loop(Found);
                elseif Found == Value then
                    return true, Index;
                end;
            elseif Operation == "Index" then
                if Index == Value then
                    return true, Found;
                end;
            end;
        end;
        return false, nil;
    end;
    return Loop(Table);
end;
local function ManageSignalsTo(Operation, Name, RBXScriptConnection)
    if Operation == "Add" then
        Signals[Name] = RBXScriptConnection;
    elseif Operation == "Remove" then
        local Found, Signal = SearchTableBy("Index", Signals, Name);
        if Found == true then
            local NewSignals = {};
            for Index, Signal in pairs(Signals) do
                if Index ~= Name then
                    NewSignals[Name] = Signal;
                end;
            end;
            if Signal.Connected == true then
                Signal:Disconnect();
            end;
            Signals = NewSignals;
        end;
    elseif Operation == "Clear" then
        if Name == nil then
            for Int, Signal in pairs(Signals) do
                if typeof(Signal) == "RBXScriptConnection" then
                    if Signal.Connected == true then
                        Signal:Disconnect();
                    end;
                end;
            end;
        else
            for Index, Signal in pairs(Signals) do
                if string.sub(Index, 1, #Name) == Name then
                    if Signal.Connected == true then
                        Signal:Disconnect();
                    end;
                end;
            end;
        end;
    end;
end;
local function AddDragTo(Moving, Button)
    local Dragging = false;
    local LastMousePosition = nil;
    local LastFramePosition = nil;
    ManageSignalsTo("Add", Form("Gui.Drag.%s-Mouse1Down", Button:GetFullName()), Button.MouseButton1Down:Connect(function()
        LastMousePosition = Vector2.new(Mouse.X, Mouse.Y);
        LastFramePosition = Moving.AbsolutePosition;
        Dragging = true;
    end));
    ManageSignalsTo("Add", Form("Gui.Drag.%s-InputEnded", Button:GetFullName()), UserInputService.InputEnded:Connect(function(Input, Processed)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false;
        end;
    end));
    ManageSignalsTo("Add", Form("Gui.Drag.%s-MouseMove", Button:GetFullName()), Mouse.Move:Connect(function()
        if Dragging == true then
            Moving.Position = UDim2.new(
                0, math.clamp(Mouse.X + (LastFramePosition.X - LastMousePosition.X), 0, Mouse.ViewSizeX - Moving.AbsoluteSize.X),
                0, math.clamp(Mouse.Y + (LastFramePosition.Y - LastMousePosition.Y), 0, (Mouse.ViewSizeY - Moving.AbsoluteSize.Y) + 36));
        end;
    end));
end;

local GuiBorderColor = Color3.fromRGB(0, 0, 0);
return function(GuiTitle, KeyTable, GuiToggleKeyBind, OnCloseCallback)
    if Genv["quex/library"] ~= nil and typeof(Genv["quex/library"].Close) == "function" then
        Genv["quex/library"].Close();
    end;
    Genv["quex/library"] = {};
    Genv = Genv["quex/library"];
    
    GuiTitle = tostring(GuiTitle) or "QUEX PROJECTS";
    GuiToggleKeyBind = ((GuiToggleKeyBind.EnumType == Enum.KeyCode) and GuiToggleKeyBind) or Enum.KeyCode.LeftControl;
    KeyTable = typeof(KeyTable) == "table" and KeyTable or {["Key"] = ""};
    KeyTable.Config = KeyTable.Config ~= nil and typeof(KeyTable.Config) == "table" and KeyTable.Config or {};
    KeyTable.Config.CaseSensitive = KeyTable.Config.CaseSensitive ~= nil and typeof(KeyTable.Config.CaseSensitive) == "boolean" and KeyTable.Config.CaseSensitive or true;
    KeyTable.Config.InputType = KeyTable.Config.InputType ~= nil and typeof(KeyTable.Config.InputType) == "string" and KeyTable.Config.InputType or "all";
    OnCloseCallback = ((typeof(OnCloseCallback) == "function") and OnCloseCallback) or function() end;
    
    local Library = Instance.new("ScreenGui");
    local Notifications = Instance.new("Frame");
    local UIListLayout = Instance.new("UIListLayout");
    
    Library.Name = Token("######-####-####-####-########", "abcdef0123456789");
    Library.Parent = game.CoreGui;
    Library.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
    
    Notifications.Name = "";
    Notifications.Parent = Library;
    Notifications.AnchorPoint = Vector2.new(0, 1);
    Notifications.AutomaticSize = Enum.AutomaticSize.Y;
    Notifications.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    Notifications.BackgroundTransparency = 1;
    Notifications.BorderSizePixel = 0;
    Notifications.Position = UDim2.new(0, 10, 1, -10);
    Notifications.Size = UDim2.new(0, 300, 0, 0);
    
    UIListLayout.Name = "";
    UIListLayout.Parent = Notifications;
    UIListLayout.FillDirection = Enum.FillDirection.Vertical;
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom;
    UIListLayout.Padding = UDim.new(0, 10);
    
    local function ShowNotification(Text1, Color, Image)
        local Notification = Instance.new("Frame");
        local UICorner = Instance.new("UICorner");
        local UIStroke = Instance.new("UIStroke");
        local Description = Instance.new("TextLabel");
        local Icon = Instance.new("ImageButton");
        
        Notification.Name = "";
        Notification.Parent = Notifications;
        Notification.AutomaticSize = Enum.AutomaticSize.Y;
        Notification.BackgroundColor3 = Color;
        Notification.BackgroundTransparency = 0.9;
        Notification.BorderSizePixel = 0;
        Notification.Size = UDim2.new(1, 0, 0, 40);
        
        UICorner.Name = "";
        UICorner.Parent = Notification;
        UICorner.CornerRadius = UDim.new(0, 10);
        
        UIStroke.Name = "";
        UIStroke.Parent = Notification;
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        UIStroke.Color = Color;
        UIStroke.LineJoinMode = Enum.LineJoinMode.Round;
        UIStroke.Thickness = 1;
        UIStroke.Transparency = 0;
        
        Icon.Name = "";
        Icon.Parent = Notification;
        Icon.Active = false;
        Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Icon.BackgroundTransparency = 1;
        Icon.BorderSizePixel = 0;
        Icon.Position = UDim2.new(0, 10, 0, 10);
        Icon.Selectable = false;
        Icon.Size = UDim2.new(0, 20, 0, 20);
        Icon.AutoButtonColor = false;
        Icon.Image = Image;
        Icon.ImageColor3 = Color;
        Icon.ScaleType = Enum.ScaleType.Fit;
        
        Description.Name = "";
        Description.Parent = Notification;
        Description.AutomaticSize = Enum.AutomaticSize.Y;
        Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Description.BackgroundTransparency = 1;
        Description.BorderSizePixel = 0;
        Description.Position = UDim2.new(0, 40, 0, 5);
        Description.Size = UDim2.new(1, -45, 0, 30);
        Description.Font = Enum.Font.Roboto;
        Description.Text = Text1;
        Description.TextColor3 = Color;
        Description.TextSize = 18;
        Description.TextWrapped = true;
        Description.TextXAlignment = Enum.TextXAlignment.Left;
        
        ManageSignalsTo("Add", Form("Gui.Notification.%s-MouseButton1Click", Text1), Icon.MouseButton1Click:Connect(function()
            Notification:Remove();
            ManageSignalsTo("Clear", Form("Gui.Notification.%s", Text1));
            Coroutine(OnCloseCallback);
        end));
        delay(5, function()
            if Notification ~= nil then
                Notification:Remove();
                ManageSignalsTo("Clear", Form("Gui.Notification.%s", Text1));
            end;
        end);
    end;
    
    if Or(KeyTable.Key, {"", " "}) == false and RemoveExtraSpaces(KeyTable.Key) ~= " " then
        local CorrectKey = false;
        
        local RequireKey = Instance.new("Frame");
        local UICorner = Instance.new("UICorner");
        local UIStroke = Instance.new("UIStroke");
        local Frame = Instance.new("Frame");
        local Title = Instance.new("TextLabel");
        local Container = Instance.new("Frame");
        local Input = Instance.new("Frame");
        local UICorner2 = Instance.new("UICorner");
        local UIStroke2 = Instance.new("UIStroke");
        local Box = Instance.new("TextBox");
        local Icon = Instance.new("ImageLabel");
        local Submit = Instance.new("TextButton");
        local UICorner3 = Instance.new("UICorner");
        local UIStroke3 = Instance.new("UIStroke");
        local Cancel = Instance.new("TextButton");
        local UICorner4 = Instance.new("UICorner");
        local UIStroke4 = Instance.new("UIStroke");
        
        RequireKey.Name = "RequireKey";
        RequireKey.Parent = Library;
        RequireKey.AnchorPoint = Vector2.new(0.5, 0.5);
        RequireKey.BackgroundColor3 = Color3.fromRGB(255, 80, 60);
        RequireKey.BackgroundTransparency = 0.9;
        RequireKey.ClipsDescendants = true;
        RequireKey.Position = UDim2.new(0.5, 0, 0.5, 0);
        RequireKey.Size = UDim2.new(0, 300, 0, 132);
        
        UICorner.Name = "";
        UICorner.Parent = RequireKey;
        
        UIStroke.Name = "";
        UIStroke.Parent = RequireKey;
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        UIStroke.Color = Color3.fromRGB(255, 80, 60);
        UIStroke.LineJoinMode = Enum.LineJoinMode.Round;
        UIStroke.Thickness = 1;
        UIStroke.Transparency = 0;
        
        Frame.Name = "";
        Frame.Parent = RequireKey;
        Frame.BackgroundColor3 = Color3.fromRGB(255, 80, 60);
        Frame.BorderSizePixel = 0;
        Frame.Position = UDim2.new(0, 0, 0, 36);
        Frame.Size = UDim2.new(1, 0, 0, 1);
        
        Title.Name = "Title";
        Title.Parent = RequireKey;
        Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Title.BackgroundTransparency = 1;
        Title.BorderSizePixel = 0;
        Title.Size = UDim2.new(1, 0, 0, 35);
        Title.Font = Enum.Font.Nunito;
        Title.Text = "KEY REQUIRED";
        Title.TextColor3 = Color3.fromRGB(255, 80, 60);
        Title.TextSize = 20;
        
        Container.Name = "Container";
        Container.Parent = RequireKey;
        Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Container.BackgroundTransparency = 1;
        Container.BorderSizePixel = 0;
        Container.Position = UDim2.new(0, 10, 0, 57);
        Container.Size = UDim2.new(1, -20, 1, -78);
        
        Input.Name = "Input";
        Input.Parent = Container;
        Input.AnchorPoint = Vector2.new(0.5, 0);
        Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Input.BackgroundTransparency = 1;
        Input.BorderSizePixel = 0;
        Input.ClipsDescendants = true;
        Input.Position = UDim2.new(0.5, 0, 0, 1);
        Input.Size = UDim2.new(1, -2, 0, 26);
        
        UICorner2.CornerRadius = UDim.new(0, 4);
        UICorner2.Name = "";
        UICorner2.Parent = Input;
        
        UIStroke2.Name = "";
        UIStroke2.Parent = Input;
        UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        UIStroke2.Color = Color3.fromRGB(255, 80, 60);
        UIStroke2.LineJoinMode = Enum.LineJoinMode.Round;
        UIStroke2.Thickness = 1;
        UIStroke2.Transparency = 0;
        
        Box.Name = "Box";
        Box.Parent = Input;
        Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Box.BackgroundTransparency = 1;
        Box.BorderColor3 = Color3.fromRGB(27, 42, 53);
        Box.BorderSizePixel = 0;
        Box.Position = UDim2.new(0, 26, 0, 0);
        Box.Size = UDim2.new(1, -31, 1, 0);
        Box.Font = Enum.Font.Roboto;
        Box.LineHeight = 0.900;
        Box.PlaceholderColor3 = Color3.fromRGB(255, 80, 60);
        Box.PlaceholderText = "Paste valid key here...";
        Box.Text = "";
        Box.TextColor3 = Color3.fromRGB(255, 80, 60);
        Box.TextSize = 12;
        Box.TextTransparency = 0.1;
        Box.TextWrapped = true;
        Box.TextXAlignment = Enum.TextXAlignment.Left;
        
        Icon.Name = "Icon";
        Icon.Parent = Input;
        Icon.Active = true;
        Icon.AnchorPoint = Vector2.new(0, 0.5);
        Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Icon.BackgroundTransparency = 1;
        Icon.BorderSizePixel = 0;
        Icon.Position = UDim2.new(0, 6, 0.5, 0);
        Icon.Selectable = true;
        Icon.Size = UDim2.new(0, 14, 0, 14);
        Icon.ZIndex = 2;
        Icon.Image = "rbxassetid://12735206387";
        Icon.ImageColor3 = Color3.fromRGB(255, 80, 60);
        Icon.ScaleType = Enum.ScaleType.Fit;
        
        Submit.Name = "Submit";
        Submit.Parent = Container;
        Submit.AnchorPoint = Vector2.new(1, 1);
        Submit.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Submit.BackgroundTransparency = 1;
        Submit.Position = UDim2.new(1, 0, 1, 0);
        Submit.Size = UDim2.new(0, 60, 0, 20);
        Submit.Font = Enum.Font.Gotham;
        Submit.Text = "submit";
        Submit.TextColor3 = Color3.fromRGB(255, 80, 60);
        Submit.TextSize = 13;
        
        UICorner3.CornerRadius = UDim.new(1, 0);
        UICorner3.Name = "";
        UICorner3.Parent = Submit;
        
        UIStroke3.Name = "";
        UIStroke3.Parent = Submit;
        UIStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        UIStroke3.Color = Color3.fromRGB(255, 80, 60);
        UIStroke3.LineJoinMode = Enum.LineJoinMode.Round;
        UIStroke3.Thickness = 1;
        UIStroke3.Transparency = 0;
        
        Cancel.Name = "Cancel";
        Cancel.Parent = Container;
        Cancel.AnchorPoint = Vector2.new(1, 1);
        Cancel.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Cancel.BackgroundTransparency = 1;
        Cancel.Position = UDim2.new(1, -72, 1, 0);
        Cancel.Size = UDim2.new(0, 60, 0, 20);
        Cancel.Font = Enum.Font.Gotham;
        Cancel.Text = "cancel";
        Cancel.TextColor3 = Color3.fromRGB(255, 80, 60);
        Cancel.TextSize = 13;
        
        UICorner4.CornerRadius = UDim.new(1, 0);
        UICorner4.Name = "";
        UICorner4.Parent = Cancel;
        
        UIStroke4.Name = "";
        UIStroke4.Parent = Cancel;
        UIStroke4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        UIStroke4.Color = Color3.fromRGB(255, 80, 60);
        UIStroke4.LineJoinMode = Enum.LineJoinMode.Round;
        UIStroke4.Thickness = 1;
        UIStroke4.Transparency = 0;
        
        ManageSignalsTo("Add", "Gui.KeyRequirement.TextBox-InputBegan", Box.InputBegan:Connect(function(Input)
            if string.lower(KeyTable.Config.InputType) == "letters" then
                Box.Text = string.gsub(Box.Text, "%d", "");
            elseif string.lower(KeyTable.Config.InputType) == "numbers" then
                Box.Text = (function()
                    local String = "";
                    for Int, Value in pairs(string.split(Box.Text, "")) do
                        if tonumber(Value) == nil then
                            String = String .. Value;
                        end;
                    end;
                    return String;
                end)();
            end;
        end));
        ManageSignalsTo("Add", "Gui.KeyRequirement.Submit-MouseButton1Click", Submit.MouseButton1Click:Connect(function()
            if (KeyTable.Config.CaseSensitive == true and Box.Text == KeyTable.Key) or (KeyTable.Config.CaseSensitive == false and string.lower(Box.Text) == string.lower(KeyTable.Key)) then
                CorrectKey = true;
                ManageSignalsTo("Clear", "Gui.KeyRequirement");
                RequireKey:Remove();
            else
                ShowNotification("Incorrect key.", Color3.fromRGB(255, 90, 90), "rbxassetid://12444748455");
            end;
        end));
        ManageSignalsTo("Add", "Gui.KeyRequirement.Cancel-MouseButton1Click", Cancel.MouseButton1Click:Connect(function()
            ManageSignalsTo("Clear");
            Library:Remove();
            return;
        end));
        repeat wait() until CorrectKey == true;
    end;
    
    local Main = Instance.new("Frame");
    local UICorner = Instance.new("UICorner");
    local UIStroke = Instance.new("UIStroke");
    local Topbar = Instance.new("Frame");
    local Close = Instance.new("ImageButton");
    local MinimizeButton = Instance.new("ImageButton")
    local Title = Instance.new("TextButton");
    local SelectionBar = Instance.new("Frame");
    local SelectionContainer = Instance.new("ScrollingFrame");
    local UIListLayout = Instance.new("UIListLayout");
    local Frame = Instance.new("Frame");
    local Frame2 = Instance.new("Frame");
    local Containers = Instance.new("Folder");
    
    local Minimized = false
    local OriginalSize = Main.Size
    local OriginalPosition = SelectionBar.Position
    
    MinimizeButton.MouseButton1Click:Connect(function()
        if not Minimized then
            Minimized = true
            Main.Size = UDim2.new(Main.Size.X.Scale, Main.Size.X.Offset, 0, 30)
            SelectionBar.Visible = false
            Containers.Visible = false
            MinimizeButton.Image = "rbxassetid://6023565891"
        else
            Minimized = false
            Main.Size = OriginalSize
            SelectionBar.Visible = true
            Containers.Visible = true
            MinimizeButton.Image = "rbxassetid://6023426926"
        end
    end)
    
    Main.Name = "";
    Main.Parent = Library;
    Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
    Main.BackgroundTransparency = 0.7;
    Main.Size = UDim2.new(0, 450, 0, 250);
    Main.Position = UDim2.new(0, (workspace.CurrentCamera.ViewportSize.X / 2) - (Main.Size.X.Offset / 2), 0, (workspace.CurrentCamera.ViewportSize.Y / 2) - (Main.Size.Y.Offset / 2));
    
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = Topbar
    MinimizeButton.AnchorPoint = Vector2.new(1, 0)
    MinimizeButton.Position = UDim2.new(1, -30, 0, 10)
    MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
    MinimizeButton.Image = "rbxassetid://6023426926"
    MinimizeButton.BackgroundTransparency = 1 
    
    UICorner.Name = "";
    UICorner.Parent = Main;
    
    UIStroke.Name = "";
    UIStroke.Parent = Main;
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
    UIStroke.Color = Color3.fromRGB(0, 0, 0);
    UIStroke.LineJoinMode = Enum.LineJoinMode.Round;
    UIStroke.Thickness = 1;
    UIStroke.Transparency = 0;
    
    Topbar.Name = "";
    Topbar.Parent = Main;
    Topbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    Topbar.BackgroundTransparency = 1;
    Topbar.BorderSizePixel = 0;
    Topbar.ClipsDescendants = true;
    Topbar.Size = UDim2.new(1, 0, 0, 30);
    
    Close.Name = "";
    Close.Parent = Topbar;
    Close.AnchorPoint = Vector2.new(1, 0);
    Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    Close.BackgroundTransparency = 1;
    Close.BorderSizePixel = 0;
    Close.Position = UDim2.new(1, -10, 0, 10);
    Close.Size = UDim2.new(0, 10, 0, 10);
    Close.ZIndex = 2;
    Close.AutoButtonColor = false;
    Close.Image = "rbxassetid://10494258175";
    Close.ImageTransparency = 0.5;
    Close.ScaleType = Enum.ScaleType.Fit;
    
    Title.Name = "";
    Title.Parent = Topbar;
    Title.AutoButtonColor = false;
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    Title.BackgroundTransparency = 1;
    Title.BorderSizePixel = 0;
    Title.Position = UDim2.new(0, 10, 0, 0);
    Title.Size = UDim2.new(1, -40, 1, 0);
    Title.ZIndex = 2;
    Title.Font = Enum.Font.RobotoMono;
    Title.LineHeight = 1.1;
    Title.Text = GuiTitle;
    Title.TextColor3 = Color3.fromRGB(255, 255, 255);
    Title.TextSize = 16;
    Title.TextXAlignment = Enum.TextXAlignment.Left;
    
    SelectionBar.Name = "";
    SelectionBar.Parent = Main;
    SelectionBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
    SelectionBar.BackgroundTransparency = 0.8;
    SelectionBar.BorderSizePixel = 0;
    SelectionBar.ClipsDescendants = true;
    SelectionBar.Position = UDim2.new(0, 0, 0, 30);
    SelectionBar.Size = UDim2.new(1, 0, 0, 31);
    
    SelectionContainer.Name = "";
    SelectionContainer.Parent = SelectionBar;
    SelectionContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
    SelectionContainer.BackgroundTransparency = 1;
    SelectionContainer.BorderSizePixel = 0;
    SelectionContainer.ClipsDescendants = false;
    SelectionContainer.Position = UDim2.new(0, 4, 0, 0);
    SelectionContainer.Selectable = false;
    SelectionContainer.Size = UDim2.new(1, -8, 1, 0);
    SelectionContainer.CanvasSize = UDim2.new(0, 0, 0, 0);
    SelectionContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
    SelectionContainer.ScrollBarThickness = 1;
    SelectionContainer.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left;
    
    UIListLayout.Name = "";
    UIListLayout.Parent = SelectionContainer;
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal;
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
    UIListLayout.Padding = UDim.new(0, 5);
    
    Frame.Name = "";
    Frame.Parent = SelectionBar;
    Frame.BackgroundColor3 = GuiBorderColor;
    Frame.BorderSizePixel = 0;
    Frame.Size = UDim2.new(1, 0, 0, 1);
    
    Frame2.Name = "";
    Frame2.Parent = SelectionBar;
    Frame2.AnchorPoint = Vector2.new(0, 1);
    Frame2.BackgroundColor3 = GuiBorderColor;
    Frame2.BorderSizePixel = 0;
    Frame2.Position = UDim2.new(0, 0, 1, 0);
    Frame2.Size = UDim2.new(1, 0, 0, 1);
    
    Containers.Name = "Containers";
    Containers.Parent = Main;
    
    
    ManageSignalsTo("Add", "Gui.Close-MouseButton1Click", Close.MouseButton1Click:Connect(function()
        ManageSignalsTo("Clear");
        GuiClosed = true;
        Library:Remove();
        Coroutine(function()
            OnCloseCallback();
        end);
    end));
    ManageSignalsTo("Add", "Gui.GuiToggleKeyBind-InputBegan", UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed == false and Input.KeyCode == GuiToggleKeyBind then
            Library.Enabled = not Library.Enabled;
        end;
    end));
    AddDragTo(Main, Title);
    
    local Service1 = {};
    function Service1:ShowNotification(Type, Text1, CountdownUntilClose, OnCloseCallback)
        Type = (tostring(Type) and Or(string.lower(Type), {"success", "suc", "information", "inf", "warning", "war", "error", "err"}) == true and string.lower(Type)) or "information";
        Text1 = tostring(Text1) or "INVALID STRING";
        CountdownUntilClose = (typeof(tonumber(CountdownUntilClose)) == "number" and CountdownUntilClose) or 30;
        OnCloseCallback = (typeof(OnCloseCallback) == "function" and OnCloseCallback) or function() end;
        
        local NotificationConfig = {
            ["Success"] = {
                ["Image"] = "rbxassetid://12444856420",
                ["Color"] = Color3.fromRGB(90, 255, 150),
            },
            ["Information"] = {
                ["Image"] = "rbxassetid://12444848354",
                ["Color"] = Color3.fromRGB(130, 180, 255),
            },
            ["Warning"] = {
                ["Image"] = "rbxassetid://12444839462",
                ["Color"] = Color3.fromRGB(255, 200, 50),
            },
            ["Error"] = {
                ["Image"] = "rbxassetid://12444748455",
                ["Color"] = Color3.fromRGB(255, 90, 90),
            },
        };
        local GetTypeConfig = function(Property)
            if Or(Type, {"success", "suc"}) == true then
                return NotificationConfig.Success[Property];
            elseif Or(Type, {"information", "inf"}) == true then
                return NotificationConfig.Information[Property];
            elseif Or(Type, {"warning", "war"}) == true then
                return NotificationConfig.Warning[Property];
            elseif Or(Type, {"error", "err"}) == true then
                return NotificationConfig.Error[Property];
            else
                return NotificationConfig.Information[Property];
            end;
        end;
        
        local Notification = Instance.new("Frame");
        local UICorner = Instance.new("UICorner");
        local UIStroke = Instance.new("UIStroke");
        local Description = Instance.new("TextLabel");
        local Icon = Instance.new("ImageButton");
        
        Notification.Name = "";
        Notification.Parent = Notifications;
        Notification.AutomaticSize = Enum.AutomaticSize.Y;
        Notification.BackgroundColor3 = GetTypeConfig("Color");
        Notification.BackgroundTransparency = 0.9;
        Notification.BorderSizePixel = 0;
        Notification.Size = UDim2.new(1, 0, 0, 40);
        
        UICorner.Name = "";
        UICorner.Parent = Notification;
        UICorner.CornerRadius = UDim.new(0, 10);
        
        UIStroke.Name = "";
        UIStroke.Parent = Notification;
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        UIStroke.Color = GetTypeConfig("Color");
        UIStroke.LineJoinMode = Enum.LineJoinMode.Round;
        UIStroke.Thickness = 1;
        UIStroke.Transparency = 0;
        
        Icon.Name = "";
        Icon.Parent = Notification;
        Icon.Active = false;
        Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Icon.BackgroundTransparency = 1;
        Icon.BorderSizePixel = 0;
        Icon.Position = UDim2.new(0, 10, 0, 10);
        Icon.Selectable = false;
        Icon.Size = UDim2.new(0, 20, 0, 20);
        Icon.AutoButtonColor = false;
        Icon.Image = GetTypeConfig("Image");
        Icon.ImageColor3 = GetTypeConfig("Color");
        Icon.ScaleType = Enum.ScaleType.Fit;
        
        Description.Name = "";
        Description.Parent = Notification;
        Description.AutomaticSize = Enum.AutomaticSize.Y;
        Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Description.BackgroundTransparency = 1;
        Description.BorderSizePixel = 0;
        Description.Position = UDim2.new(0, 40, 0, 5);
        Description.Size = UDim2.new(1, -45, 0, 30);
        Description.Font = Enum.Font.Roboto;
        Description.Text = Text1;
        Description.TextColor3 = GetTypeConfig("Color");
        Description.TextSize = 18;
        Description.TextWrapped = true;
        Description.TextXAlignment = Enum.TextXAlignment.Left;
        
        ManageSignalsTo("Add", Form("Gui.Notification.%s.%s-MouseButton1Click", Type, Text1), Icon.MouseButton1Click:Connect(function()
            Notification:Remove();
            ManageSignalsTo("Clear", Form("Gui.Notification.%s.%s", Type, Text1));
            Coroutine(OnCloseCallback);
        end));
        
        local Service3 = {};
        function Service3:Close()
            Notification:Remove();
            ManageSignalsTo("Clear", Form("Gui.Notification.%s.%s", Type, Text1));
            Coroutine(OnCloseCallback);
        end;
        delay(CountdownUntilClose, function()
            Service3:Close();
        end);
        return Service3;
    end;
    function Service1:ChangeBorderColorTo(Color)
        Color = (typeof(Color) == "Color3" and Color) or Color3.fromRGB(0, 0, 0);
        
        GuiBorderColor = Color;
        UIStroke.Color = Color;
        Frame.BackgroundColor3 = Color;
        Frame2.BackgroundColor3 = Color;
        for Int1, Value1 in pairs(Containers:GetChildren()) do
            for Int2, Value2 in pairs(Value1:GetDescendants()) do
                if Value1.Name == "Seperator" then
                    Value1.BackgroundColor3 = Color;
                elseif Value2.ClassName == "Frame" and Value2.Name == "" then
                    Value2.BackgroundColor3 = Color;
                end;
            end;
        end;
    end;
    function Service1:AddTab(Text1)
        Text1 = tostring(Text1) or "INVALID STRING";
        
        local Container = Instance.new("ScrollingFrame");
        local UIListLayout = Instance.new("UIListLayout");
        local Selection = Instance.new("ImageButton");
        local Label = Instance.new("TextLabel");
        local Frame = Instance.new("Frame");
        local UICorner = Instance.new("UICorner");
        local UIStroke = Instance.new("UIStroke");
        
        Container.Name = Text1;
        Container.Parent = Containers;
        Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Container.BackgroundTransparency = 1;
        Container.BorderSizePixel = 0;
        Container.Position = UDim2.new(0, 0, 0, 61);
        Container.Selectable = false;
        Container.Size = UDim2.new(1, 0, 1, -61);
        Container.Visible = false;
        Container.AutomaticCanvasSize = Enum.AutomaticSize.Y;
        Container.CanvasSize = UDim2.new(0, 0, 0, 0);
        Container.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable;
        Container.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0);
        Container.ScrollBarImageTransparency = 0;
        Container.ScrollBarThickness = 1;
        Container.ScrollingDirection = Enum.ScrollingDirection.Y;
        Container.ScrollingEnabled = true;
        Container.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right;
        
        UIListLayout.Name = "";
        UIListLayout.Parent = Container;
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
        UIListLayout.Padding = UDim.new(0, 1);
        
        Selection.Name = Text1;
        Selection.Parent = SelectionContainer;
        Selection.Active = false;
        Selection.AutomaticSize = Enum.AutomaticSize.X;
        Selection.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Selection.BackgroundTransparency = 1;
        Selection.BorderSizePixel = 0;
        Selection.Selectable = false;
        Selection.Size = UDim2.new(0, 0, 0, 21);
        Selection.AutoButtonColor = false;
        
        Label.Name = "Label";
        Label.Parent = Selection;
        Label.AutomaticSize = Enum.AutomaticSize.X;
        Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        Label.BackgroundTransparency = 1;
        Label.BorderSizePixel = 0;
        Label.Position = UDim2.new(0, 10, 0, 0);
        Label.Size = UDim2.new(0, 0, 1, 0);
        Label.ZIndex = 2;
        Label.Font = Enum.Font.Roboto;
        Label.Text = Text1;
        Label.TextColor3 = Color3.fromRGB(255, 255, 255);
        Label.TextSize = 14;
        Label.TextTransparency = 0.2;
        
        Frame.Name = "";
        Frame.Parent = Selection;
        Frame.BackgroundColor3 = GuiBorderColor;
        Frame.BackgroundTransparency = 0.8;
        Frame.BorderSizePixel = 0;
        Frame.Position = UDim2.new(0, 1, 0, 1);
        Frame.Size = UDim2.new(1, 7, 1, -2);
        
        UICorner.Name = "";
        UICorner.Parent = Frame;
        UICorner.CornerRadius = UDim.new(1, 0);
        
        UIStroke.Name = "";
        UIStroke.Parent = Frame;
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        UIStroke.Color = GuiBorderColor;
        UIStroke.LineJoinMode = Enum.LineJoinMode.Round;
        UIStroke.Thickness = 1;
        UIStroke.Transparency = 0.5;
        
        ManageSignalsTo("Add", Form("Selection.%s-MouseEnter", Text1), Selection.MouseEnter:Connect(function()
            if Frame.BackgroundColor3 ~= Color3.fromRGB(140, 140, 140) and Label.TextColor3 ~= (GuiBorderColor == Color3.fromRGB(0, 0, 0) and Color3.fromRGB(84, 255, 241) or GuiBorderColor) then
                Frame.BackgroundColor3 = Color3.fromRGB(140, 140, 140);
                UIStroke.Color = Color3.fromRGB(130, 130, 130);
                Selection.MouseLeave:Wait();
                if Label.TextColor3 ~= (GuiBorderColor == Color3.fromRGB(0, 0, 0) and Color3.fromRGB(84, 255, 241) or GuiBorderColor) then
                    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
                    UIStroke.Color = Color3.fromRGB(0, 0, 0);
                end;
            end;
        end));
        ManageSignalsTo("Add", Form("Selection.%s-MouseButton1Click", Text1), Selection.MouseButton1Click:Connect(function()
            for Int, Selector in pairs(SelectionContainer:GetChildren()) do
                if Selector.ClassName == "ImageButton" then
                    if Selector:FindFirstChildOfClass("Frame") ~= nil and Selector:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("UIStroke") ~= nil then
                        Selector:FindFirstChildOfClass("Frame").BackgroundColor3 = Color3.fromRGB(0, 0, 0);
                        Selector:FindFirstChildOfClass("Frame").BackgroundTransparency = 0.8;
                        Selector:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(0, 0, 0);
                        Selector.Label.TextColor3 = Color3.fromRGB(255, 255, 255);
                    end;
                end;
            end;
            Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
            Frame.BackgroundTransparency = 1;
            UIStroke.Color = GuiBorderColor == Color3.fromRGB(0, 0, 0) and Color3.fromRGB(84, 255, 241) or GuiBorderColor;
            Label.TextColor3 = GuiBorderColor == Color3.fromRGB(0, 0, 0) and Color3.fromRGB(84, 255, 241) or GuiBorderColor;
            Container.Visible = true;
            for Int, Value in pairs(Containers:GetChildren()) do
                if Value.ClassName == "ScrollingFrame" and Value ~= Container then
                    Value.Visible = false;
                end;
            end;
        end));
        
        local Service2 = {};
        function Service2:AddSeperator()
            local Seperator = Instance.new("Frame");
            Seperator.Name = "Seperator";
            Seperator.Parent = Container;
            Seperator.BackgroundColor3 = GuiBorderColor;
            Seperator.BorderSizePixel = 0;
            Seperator.Size = UDim2.new(1, 0, 0, 1);
            
            local Service3 = {};
            function Service3:Remove()
                Label:Remove();
            end;
            return Service3;
        end;
        function Service2:AddLabel(Text)
            Text = tostring(Text) or "INVALID STRING";
            
            local Label = Instance.new("ImageButton");
            local Frame = Instance.new("Frame");
            local Description = Instance.new("TextLabel");
            
            Label.Name = "Label";
            Label.Parent = Container;
            Label.Active = false;
            Label.AutomaticSize = Enum.AutomaticSize.Y;
            Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Label.BackgroundTransparency = 1;
            Label.Selectable = false;
            Label.Size = UDim2.new(1, 0, 0, 20);
            Label.AutoButtonColor = false;
            
            Frame.Name = "";
            Frame.Parent = Label;
            Frame.BackgroundColor3 = GuiBorderColor;
            Frame.BackgroundTransparency = 0.9;
            Frame.BorderSizePixel = 0;
            Frame.Position = UDim2.new(0, 0, 1, 0);
            Frame.Size = UDim2.new(1, 0, 0, 1);
            
            Description.Name = "";
            Description.Parent = Label;
            Description.AutomaticSize = Enum.AutomaticSize.Y;
            Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Description.BackgroundTransparency = 1;
            Description.BorderSizePixel = 0;
            Description.Position = UDim2.new(0, 10, 0, 0);
            Description.Size = UDim2.new(1, -20, 1, 0);
            Description.Font = Enum.Font.SourceSansItalic;
            Description.Text = Text;
            Description.TextColor3 = Color3.fromRGB(255, 255, 255);
            Description.TextSize = 18;
            Description.TextWrapped = true;
            Description.TextXAlignment = Enum.TextXAlignment.Left;
            
            local Service3 = {["Description"] = Text1};
            setmetatable(Service3, {
                __index = function(Table, Key)
                    if Key == "Description" then
                        return Description.Text;
                    end;
                end,
                __newindex = function(Table, Key, Value)
                    if Key == "Description" and typeof(Value) == "string" then
                        Description.Text = Value;
                    end;
                    rawset(Table, Key, Value);
                end,
            });
            function Service3:Remove()
                Label:Remove();
            end;
            return Service3;
        end;
        function Service2:AddButton(Text1, Text2, Text3, Function)
            Text1 = tostring(Text1) or "INVALID STRING";
            Text2 = tostring(Text2) or "INVALID STRING";
            Text3 = tostring(Text3) or "INVALID STRING";
            Function = (typeof(Function) == "function" and Function) or function() end;
            
            local Button = Instance.new("ImageButton");
            local Frame = Instance.new("Frame");
            local Title = Instance.new("TextLabel");
            local Description = Instance.new("TextLabel");
            local Icon = Instance.new("ImageLabel");
            local Click = Instance.new("ImageLabel");
            
            Button.Name = "Button";
            Button.Parent = Container;
            Button.Active = false;
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Button.BackgroundTransparency = 1;
            Button.Selectable = false;
            Button.Size = UDim2.new(1, 0, 0, 40);
            Button.AutoButtonColor = false;
            
            Frame.Name = "";
            Frame.Parent = Button;
            Frame.BackgroundColor3 = GuiBorderColor;
            Frame.BackgroundTransparency = 0.9;
            Frame.BorderSizePixel = 0;
            Frame.Position = UDim2.new(0, 0, 1, 0);
            Frame.Size = UDim2.new(1, 0, 0, 1);
            
            Title.Name = "";
            Title.Parent = Button;
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Title.BackgroundTransparency = 1;
            Title.BorderSizePixel = 0;
            Title.Position = UDim2.new(0, 40, 0, 4);
            Title.Size = UDim2.new(1, -79, 0.5, 0);
            Title.Font = Enum.Font.SourceSans;
            Title.Text = Text1;
            Title.TextColor3 = Color3.fromRGB(255, 255, 255);
            Title.TextSize = 17;
            Title.TextXAlignment = Enum.TextXAlignment.Left;
            Title.TextYAlignment = Enum.TextYAlignment.Top;
            
            Description.Name = "";
            Description.Parent = Button;
            Description.AnchorPoint = Vector2.new(0, 1);
            Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Description.BackgroundTransparency = 1;
            Description.BorderSizePixel = 0;
            Description.Position = UDim2.new(0, 40, 1, -4);
            Description.Size = UDim2.new(1, -79, 0.5, 0);
            Description.Font = Enum.Font.SourceSans;
            Description.Text = Text2;
            Description.TextColor3 = Color3.fromRGB(255, 255, 255);
            Description.TextSize = 15;
            Description.TextTransparency = 0.3;
            Description.TextXAlignment = Enum.TextXAlignment.Left;
            Description.TextYAlignment = Enum.TextYAlignment.Bottom;
            
            Icon.Name = "";
            Icon.Parent = Button;
            Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Icon.BackgroundTransparency = 1;
            Icon.BorderSizePixel = 0;
            Icon.Position = UDim2.new(0, 5, 0, 5);
            Icon.Size = UDim2.new(0, 30, 0, 30);
            Icon.Image = Text3 == "" and "http://www.roblox.com/asset/?id=14353037120" or Text3;
            Icon.ScaleType = Enum.ScaleType.Fit;
            
            Click.Name = "";
            Click.Parent = Button;
            Click.AnchorPoint = Vector2.new(1, 0.5);
            Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Click.BackgroundTransparency = 1;
            Click.BorderSizePixel = 0;
            Click.Position = UDim2.new(1, -4, 0.5, 0);
            Click.Size = UDim2.new(0, 25, 0, 25);
            Click.Image = "rbxassetid://11802077499";
            Click.ImageColor3 = Color3.fromRGB(0, 0, 0);
            Click.ImageTransparency = 0.5;
            Click.ScaleType = Enum.ScaleType.Fit;
            
            ManageSignalsTo("Add", Form("Element.Button.%s.%s-MouseButton1Click", Text1, Text2), Button.MouseButton1Click:Connect(function()
                xpcall(function()
                    Coroutine(Function);
                end, function(Message)
                    warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                end);
            end));
            
            local Service3 = {["Disabled"] = false, ["Title"] = Text1, ["Description"] = Text2, ["Image"] = Text3};
            setmetatable(Service3, {
                __index = function(Table, Key)
                    if Key == "Disabled" then
                        return rawget(Service3, Key);
                    elseif Key == "Title" then
                        return Title.Text;
                    elseif Key == "Description" then
                        return Description.Text;
                    elseif Key == "Image" then
                        return Icon.Image;
                    end;
                end,
                __newindex = function(Table, Key, Value)
                    if Key == "Disabled" and typeof(Value) == "boolean" then
                        -- TODO
                        elseif Key == "Title" and typeof(Value) == "string" then
                        Title.Text = Value;
                        elseif Key == "Description" and typeof(Value) == "string" then
                            Description.Text = Value;
                        elseif Key == "Image" and typeof(Value) == "string" then
                            Icon.Image = Value;
                        end;
                        rawset(Table, Key, Value);
                end,
            });
            function Service3:CallFunction(...)
                local Arguments = {...};
                xpcall(function()
                    Coroutine(function()
                        Function(table.unpack(Arguments));
                    end);
                end, function(Message)
                    warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                end);
            end;
            function Service3:Remove()
                ManageSignalsTo("Clear", Form("Element.Button.%s.%s", Text1, Text2));
                Button:Remove();
            end;
            return Service3;
        end;
        function Service2:AddDiscord(Text1, InviteCode)
            Text1 = tostring(Text1) or "INVALID STRING";
            InviteCode = tostring(InviteCode) or "7EJ9MunQTt";
            
            if isfile ~= nil then
                if isfile("Discord.png") == false then
                    writefile("Discord.png", Request{Url = "https://i.imgur.com/5XrocCA.png", Method = "GET"}.Body);
                end;
            end;
            
            local Discord = Instance.new("ImageButton");
            local Frame = Instance.new("Frame");
            local Title = Instance.new("TextLabel");
            local Icon = Instance.new("ImageLabel");
            local Click = Instance.new("ImageLabel");
            local UIGradient = Instance.new("UIGradient");
            
            Discord.Name = "Discord";
            Discord.Parent = Container;
            Discord.Active = false;
            Discord.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Discord.BorderSizePixel = 0;
            Discord.Selectable = false;
            Discord.Size = UDim2.new(1, 0, 0, 40);
            Discord.AutoButtonColor = false;
            
            Frame.Name = "";
            Frame.Parent = Discord;
            Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
            Frame.BackgroundTransparency = 0.9;
            Frame.BorderSizePixel = 0;
            Frame.Position = UDim2.new(0, 0, 1, 0);
            Frame.Size = UDim2.new(1, 0, 0, 1);
            
            Title.Name = "";
            Title.Parent = Discord;
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Title.BackgroundTransparency = 1;
            Title.BorderColor3 = Color3.fromRGB(27, 42, 53);
            Title.BorderSizePixel = 0;
            Title.Position = UDim2.new(0, 40, 0, 4);
            Title.Size = UDim2.new(1, -79, 1, -8);
            Title.Font = Enum.Font.SourceSans;
            Title.Text = Text1;
            Title.TextColor3 = Color3.fromRGB(255, 255, 255);
            Title.TextSize = 18;
            Title.TextXAlignment = Enum.TextXAlignment.Left;
            
            Icon.Name = "";
            Icon.Parent = Discord;
            Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Icon.BackgroundTransparency = 1;
            Icon.BorderSizePixel = 0;
            Icon.Position = UDim2.new(0, 5, 0, 5);
            Icon.Size = UDim2.new(0, 30, 0, 30);
            Icon.Image = isfile ~= nil and GetAsset("Discord.png") or "";
            Icon.ScaleType = Enum.ScaleType.Fit;
            
            Click.Name = "";
            Click.Parent = Discord;
            Click.AnchorPoint = Vector2.new(1, 0.5);
            Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Click.BackgroundTransparency = 1;
            Click.BorderSizePixel = 0;
            Click.Position = UDim2.new(1, -4, 0.5, 0);
            Click.Size = UDim2.new(0, 25, 0, 25);
            Click.Image = "rbxassetid://11802077499";
            Click.ImageColor3 = Color3.fromRGB(0, 0, 0);
            Click.ImageTransparency = 0.5;
            Click.ScaleType = Enum.ScaleType.Fit;
            
            UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(86, 98, 246)), ColorSequenceKeypoint.new(1, Color3.fromRGB(86, 98, 246))};
            UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.33, 0.73), NumberSequenceKeypoint.new(0.58, 1), NumberSequenceKeypoint.new(1, 1)};
            UIGradient.Parent = Discord;
            
            ManageSignalsTo("Add", Form("Element.Discord.%s.%s-MouseButton1Click", Text1, InviteCode), Discord.MouseButton1Click:Connect(function()
                Request{
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["origin"] = "https://ptb.discord.com",
                    },
                    Body = game:GetService("HttpService"):JSONEncode{
                        ["args"] = {["code"] = InviteCode},
                        ["cmd"] = "INVITE_BROWSER",
                        ["nonce"] = tostring(os.time()),
                    },
                };
            end));
            
            local Service3 = {["Disabled"] = false, ["Title"] = Text1, ["InviteCode"] = InviteCode};
            setmetatable(Service3, {
                __index = function(Table, Key)
                    if Key == "Disabled" then
                        return rawget(Service3, Key);
                    elseif Key == "Title" then
                        return Title.Text;
                    end;
                end,
                __newindex = function(Table, Key, Value)
                    if Key == "Disabled" and typeof(Value) == "boolean" then
                        -- TODO
                        elseif Key == "Title" and typeof(Value) == "string" then
                        Title.Text = Value;
                        elseif Key == "InviteCode" and typeof(Value) == "string" then
                            -- TODO
                            end;
                        rawset(Table, Key, Value);
                end,
            });
            function Service3:Remove()
                ManageSignalsTo("Clear", Form("Element.Discord.%s.%s-MouseButton1Click", Text1, InviteCode));
                Discord:Remove();
            end;
            return Service3;
        end;
        function Service2:AddToggle(Text1, Text2, Text3, StartValue, Function)
            Text1 = tostring(Text1) or "INVALID STRING";
            Text2 = tostring(Text2) or "INVALID STRING";
            Text3 = tostring(Text3) or "INVALID STRING";
            StartValue = (typeof(StartValue) == "boolean" and StartValue) or false;
            Function = (typeof(Function) == "function" and Function) or function() end;
            
            local Toggle = Instance.new("ImageButton");
            local Frame = Instance.new("Frame");
            local Title = Instance.new("TextLabel");
            local Description = Instance.new("TextLabel");
            local Icon = Instance.new("ImageLabel");
            local Index = Instance.new("Frame");
            local UICorner = Instance.new("UICorner");
            local UIStroke = Instance.new("UIStroke");
            local Dot = Instance.new("Frame");
            local UICorner2 = Instance.new("UICorner");
            
            Toggle.Name = "Toggle";
            Toggle.Parent = Container;
            Toggle.Active = false;
            Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Toggle.BackgroundTransparency = 1;
            Toggle.Selectable = false;
            Toggle.Size = UDim2.new(1, 0, 0, 40);
            Toggle.AutoButtonColor = false;
            
            Frame.Name = "";
            Frame.Parent = Toggle;
            Frame.BackgroundColor3 = GuiBorderColor;
            Frame.BackgroundTransparency = 0.9;
            Frame.BorderSizePixel = 0;
            Frame.Position = UDim2.new(0, 0, 1, 0);
            Frame.Size = UDim2.new(1, 0, 0, 1);
            
            Title.Name = "";
            Title.Parent = Toggle;
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Title.BackgroundTransparency = 1;
            Title.BorderSizePixel = 0;
            Title.Position = UDim2.new(0, 40, 0, 4);
            Title.Size = UDim2.new(1, -79, 0.5, 0);
            Title.Font = Enum.Font.SourceSans;
            Title.Text = Text1;
            Title.TextColor3 = Color3.fromRGB(255, 255, 255);
            Title.TextSize = 17;
            Title.TextXAlignment = Enum.TextXAlignment.Left;
            Title.TextYAlignment = Enum.TextYAlignment.Top;
            
            Description.Name = "";
            Description.Parent = Toggle;
            Description.AnchorPoint = Vector2.new(0, 1);
            Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Description.BackgroundTransparency = 1;
            Description.BorderSizePixel = 0;
            Description.Position = UDim2.new(0, 40, 1, -4);
            Description.Size = UDim2.new(1, -79, 0.5, 0);
            Description.Font = Enum.Font.SourceSans;
            Description.Text = Text2;
            Description.TextColor3 = Color3.fromRGB(255, 255, 255);
            Description.TextSize = 15;
            Description.TextTransparency = 0.3;
            Description.TextXAlignment = Enum.TextXAlignment.Left;
            Description.TextYAlignment = Enum.TextYAlignment.Bottom;
            
            Icon.Name = "";
            Icon.Parent = Toggle;
            Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Icon.BackgroundTransparency = 1;
            Icon.BorderSizePixel = 0;
            Icon.Position = UDim2.new(0, 5, 0, 5);
            Icon.Size = UDim2.new(0, 30, 0, 30);
            Icon.Image = Text3 == "" and "http://www.roblox.com/asset/?id=14353037120" or Text3;
            Icon.ScaleType = Enum.ScaleType.Fit;
            
            Index.Name = "";
            Index.Parent = Toggle;
            Index.AnchorPoint = Vector2.new(1, 0.5);
            Index.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Index.BackgroundTransparency = 1;
            Index.BorderSizePixel = 0;
            Index.Position = UDim2.new(1, -5, 0.5, 0);
            Index.Size = UDim2.new(0, 28, 0, 15);
            
            UICorner.Name = "";
            UICorner.Parent = Index;
            UICorner.CornerRadius = UDim.new(1, 0);
            
            UIStroke.Name = "";
            UIStroke.Parent = Index;
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            UIStroke.Color = StartValue == true and Color3.fromRGB(84, 255, 241) or Color3.fromRGB(0, 0, 0);
            UIStroke.LineJoinMode = Enum.LineJoinMode.Round;
            UIStroke.Thickness = 1;
            UIStroke.Transparency = StartValue == true and 0 or 0.5;
            
            Dot.Name = "";
            Dot.Parent = Index;
            Dot.BackgroundColor3 = StartValue == true and Color3.fromRGB(84, 255, 241) or Color3.fromRGB(0, 0, 0);
            Dot.BackgroundTransparency = StartValue == true and 0 or 0.5;
            Dot.Position = UDim2.new(0, (StartValue == true and 14 or 1), 0, 1);
            Dot.Size = UDim2.new(0, 13, 0, 13);
            
            UICorner2.Name = "";
            UICorner2.Parent = Dot;
            UICorner2.CornerRadius = UDim.new(1, 0);
            
            ManageSignalsTo("Add", Form("Element.Toggle.%s.%s-MouseButton1Click", Text1, Text2), Toggle.MouseButton1Click:Connect(function()
                xpcall(function()
                    UIStroke.Color = Dot.Position.X.Offset == 1 and Color3.fromRGB(84, 255, 241) or Color3.fromRGB(0, 0, 0);
                    UIStroke.Transparency = Dot.Position.X.Offset == 1 and 0 or 0.5
                    Dot.BackgroundColor3 = Dot.Position.X.Offset == 1 and Color3.fromRGB(84, 255, 241) or Color3.fromRGB(0, 0, 0);
                    Dot.Position = UDim2.new(0, (Dot.Position.X.Offset == 1 and 14 or 1), 0, 1);
                    Dot.BackgroundTransparency = Dot.Position.X.Offset == 14 and 0 or 0.5;
                    Coroutine(function()
                        Function(Dot.Position.X.Offset == 14);
                    end);
                end, function(Message)
                    warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                end);
            end));
            
            local Service3 = {["Disabled"] = false, ["Title"] = Text1, ["Description"] = Text2, ["Image"] = Text3, ["Value"] = StartValue};
            setmetatable(Service3, {
                __index = function(Table, Key)
                    if Key == "Disabled" then
                        return rawget(Service3, Key);
                    elseif Key == "Title" then
                        return Title.Text;
                    elseif Key == "Description" then
                        return Description.Text;
                    elseif Key == "Image" then
                        return Icon.Image;
                    end;
                end,
                __newindex = function(Table, Key, Value)
                    if Key == "Disabled" and typeof(Value) == "boolean" then
                        -- TODO
                        elseif Key == "Title" and typeof(Value) == "string" then
                        Title.Text = Value;
                        elseif Key == "Description" and typeof(Value) == "string" then
                            Description.Text = Value;
                        elseif Key == "Image" and typeof(Value) == "string" then
                            Icon.Image = Value;
                        elseif Key == "Value" and typeof(Value) == "boolean" then
                            UIStroke.Color = Value == true and Color3.fromRGB(84, 255, 241) or Color3.fromRGB(0, 0, 0);
                            UIStroke.Transparency = Value == true and 0 or 0.5;
                            Dot.BackgroundColor3 = Value == true and Color3.fromRGB(84, 255, 241) or Color3.fromRGB(0, 0, 0);
                            Dot.Position = UDim2.new(0, (Value == true and 14 or 1), 0, 1);
                            Dot.BackgroundTransparency = Value == true and 0 or 0.5;
                            Function(Value);
                        end;
                        rawset(Table, Key, Value);
                end,
            });
            function Service3:CallFunction(...)
                local Arguments = {...};
                xpcall(function()
                    Coroutine(function()
                        Function(table.unpack(Arguments));
                    end);
                end, function(Message)
                    warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                end);
            end;
            function Service3:Remove()
                ManageSignalsTo("Clear", Form("Element.Toggle.%s.%s", Text1, Text2));
                Toggle:Remove();
            end;
            return Service3;
        end;
        function Service2:AddSlider(Text1, Text2, Text3, MinimumValue, MaximumValue, IncreasementValue, StartValue, Function)
            Text1 = tostring(Text1) or "INVALID STRING";
            Text2 = tostring(Text2) or "INVALID STRING";
            Text3 = tostring(Text3) or "INVALID STRING";
            MinimumValue = (typeof(MinimumValue) == "number" and MinimumValue) or 0;
            MaximumValue = (typeof(MaximumValue) == "number" and MaximumValue) or 100;
            IncreasementValue = (typeof(IncreasementValue) == "number" and IncreasementValue) or 1;
            StartValue = (typeof(StartValue) == "number" and StartValue) or 50;
            Function = (typeof(Function) == "function" and Function) or function() end;
            
            local Service3 = {["Disabled"] = false, ["Title"] = Text1, ["Description"] = Text2, ["Image"] = Text3, ["Value"] = StartValue};
            setmetatable(Service3, {
                __index = function(Table, Key)
                    if Key == "Disabled" then
                        return rawget(Service3, Key);
                    elseif Key == "Title" then
                        return ""; --Title.Text;
                    elseif Key == "Description" then
                        return ""; --Description.Text;
                    elseif Key == "Image" then
                        return ""; --Icon.Image;
                    end;
                end,
                __newindex = function(Table, Key, Value)
                    if Key == "Disabled" and typeof(Value) == "boolean" then
                        -- TODO
                        elseif Key == "Title" and typeof(Value) == "string" then
                        --Title.Text = Value;
                        elseif Key == "Description" and typeof(Value) == "string" then
                            --Description.Text = Value;
                            elseif Key == "Image" and typeof(Value) == "string" then
                            --Icon.Image = Value;
                            end;
                            rawset(Table, Key, Value);
                end,
            });
            function Service3:CallFunction(...)
                local Arguments = {...};
                xpcall(function()
                    Coroutine(function()
                        Function(table.unpack(Arguments));
                    end);
                end, function(Message)
                    warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                end);
            end;
            function Service3:Remove()
            end;
            return Service3;
        end;
        function Service2:AddDropdown(Text1, Text2, Text3, StartList, StartValue, Function)
            Text1 = tostring(Text1) or "INVALID STRING";
            Text2 = tostring(Text2) or "INVALID STRING";
            Text3 = tostring(Text3) or "INVALID STRING";
            StartList = ((typeof(StartList) == "table") and (#StartList > 0) and StartList) or {"INVALID STRING"};
            StartValue = tostring(StartValue) or "INVALID STRING";
            Function = (typeof(Function) == "function" and Function) or function() end;
            
            local Service3 = {["Disabled"] = false, ["Title"] = Text1, ["Description"] = Text2, ["Image"] = Text3, ["Selected"] = StartValue, ["Items"] = StartList};
            setmetatable(Service3, {
                __index = function(Table, Key)
                    if Key == "Disabled" then
                        return rawget(Service3, Key);
                    elseif Key == "Title" then
                        return ""; --Title.Text;
                    elseif Key == "Description" then
                        return ""; --Description.Text;
                    elseif Key == "Image" then
                        return ""; --Icon.Image;
                    elseif Key == "Selected" then
                        return ""; --
                    elseif Key == "Items" then
                        return {}; --
                    end;
                end,
                __newindex = function(Table, Key, Value)
                    if Key == "Disabled" and typeof(Value) == "boolean" then
                        -- TODO
                        elseif Key == "Title" and typeof(Value) == "string" then
                        --Title.Text = Value;
                        elseif Key == "Description" and typeof(Value) == "string" then
                            --Description.Text = Value;
                            elseif Key == "Image" and typeof(Value) == "string" then
                            --Icon.Image = Value;
                            end;
                            if Or(Key, {"Disabled", "Title", "Description", "Image"}) == true then
                                rawset(Table, Key, Value);
                            end;
                end,
            });
            function Service3:AddListItem(ListItemName)
            end;
            function Service3:RemoveListItem(ListItemName)
            end;
            function Service3:EmptyList()
            end;
            function Service3:CallFunction(...)
                local Arguments = {...};
                xpcall(function()
                    Coroutine(function()
                        Function(table.unpack(Arguments));
                    end);
                end, function(Message)
                    warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                end);
            end;
            function Service3:Remove()
            end;
            return Service3;
        end;
        function Service2:AddColorPicker(Text1, Text2, Text3, StartValue, Function)
            Text1 = tostring(Text1) or "INVALID STRING";
            Text2 = tostring(Text2) or "INVALID STRING";
            Text3 = tostring(Text3) or "INVALID STRING";
            StartValue = (typeof(StartValue) == "Color3" and StartValue) or Color3.fromRGB(255, 255, 255);
            Function = (typeof(Function) == "function" and Function) or function() end;
            
            local Service3 = {["Disabled"] = false, ["Title"] = Text1, ["Description"] = Text2, ["Image"] = Text3, ["Color"] = StartValue};
            setmetatable(Service3, {
                __index = function(Table, Key)
                    if Key == "Disabled" then
                        return rawget(Service3, Key);
                    elseif Key == "Title" then
                        return ""; --Title.Text;
                    elseif Key == "Description" then
                        return ""; --Description.Text;
                    elseif Key == "Image" then
                        return ""; --Icon.Image;
                    elseif Key == "Color" then
                        return rawget(Service3, "Color");
                    end;
                end,
                __newindex = function(Table, Key, Value)
                    if Key == "Disabled" and typeof(Value) == "boolean" then
                        -- TODO
                        elseif Key == "Title" and typeof(Value) == "string" then
                        --Title.Text = Value;
                        elseif Key == "Description" and typeof(Value) == "string" then
                            --Description.Text = Value;
                            elseif Key == "Image" and typeof(Value) == "string" then
                            --Icon.Image = Value;
                            elseif Key == "Color" and typeof(Value) == "Color3" then
                                --
                                end;
                            rawset(Table, Key, Value);
                end,
            });
            function Service3:CallFunction(...)
                local Arguments = {...};
                xpcall(function()
                    Coroutine(function()
                        Function(table.unpack(Arguments));
                    end);
                end, function(Message)
                    warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                end);
            end;
            function Service3:Remove()
            end;
            return Service3;
        end;
        function Service2:AddTextBox(Text1, Text2, Text3, InputType, StartValue, Function)
            Text1 = tostring(Text1) or "INVALID STRING";
            Text2 = tostring(Text2) or "INVALID STRING";
            Text3 = (tostring(Text3) and tostring(Text3) == "" and tostring(Text3)) or "http://www.roblox.com/asset/?id=14353037120";
            InputType = (tostring(InputType) and Or(string.lower(InputType), {"all", "letters", "numbers"}) == true and InputType) or "all";
            StartValue = tostring(StartValue) or "INVALID STRING";
            Function = (typeof(Function) == "function" and Function) or function() end;
            
            local Focused = false;
            
            local TextBox = Instance.new("ImageButton");
            local Frame = Instance.new("Frame");
            local Title = Instance.new("TextLabel");
            local Description = Instance.new("TextLabel");
            local Icon = Instance.new("ImageLabel");
            local Index = Instance.new("Frame");
            local UICorner = Instance.new("UICorner");
            local UIStroke = Instance.new("UIStroke");
            local Type = Instance.new("TextBox");
            local Frame2 = Instance.new("Frame");
            
            TextBox.Name = "TextBox";
            TextBox.Parent = Container;
            TextBox.Active = false;
            TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            TextBox.BackgroundTransparency = 1;
            TextBox.Selectable = false;
            TextBox.Size = UDim2.new(1, 0, 0, 40);
            TextBox.AutoButtonColor = false;
            
            Frame.Name = "";
            Frame.Parent = TextBox;
            Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
            Frame.BackgroundTransparency = 0.9;
            Frame.BorderSizePixel = 0;
            Frame.Position = UDim2.new(0, 0, 1, 0);
            Frame.Size = UDim2.new(1, 0, 0, 1);
            
            Title.Name = "";
            Title.Parent = TextBox;
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Title.BackgroundTransparency = 1;
            Title.BorderSizePixel = 0;
            Title.Position = UDim2.new(0, 40, 0, 4);
            Title.Size = UDim2.new(1, -254, 0.5, 0);
            Title.Font = Enum.Font.SourceSans;
            Title.Text = Text1;
            Title.TextColor3 = Color3.fromRGB(255, 255, 255);
            Title.TextSize = 17;
            Title.TextXAlignment = Enum.TextXAlignment.Left;
            Title.TextYAlignment = Enum.TextYAlignment.Top;
            
            Description.Name = "";
            Description.Parent = TextBox;
            Description.AnchorPoint = Vector2.new(0, 1);
            Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Description.BackgroundTransparency = 1;
            Description.BorderSizePixel = 0;
            Description.Position = UDim2.new(0, 40, 1, -4);
            Description.Size = UDim2.new(1, -254, 0.5, 0);
            Description.Font = Enum.Font.SourceSans;
            Description.Text = Text2;
            Description.TextColor3 = Color3.fromRGB(255, 255, 255);
            Description.TextSize = 15;
            Description.TextTransparency = 0.3;
            Description.TextXAlignment = Enum.TextXAlignment.Left;
            Description.TextYAlignment = Enum.TextYAlignment.Bottom;
            
            Icon.Name = "";
            Icon.Parent = TextBox;
            Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Icon.BackgroundTransparency = 1;
            Icon.BorderSizePixel = 0;
            Icon.Position = UDim2.new(0, 5, 0, 5);
            Icon.Size = UDim2.new(0, 30, 0, 30);
            Icon.Image = Text3 == "" and "http://www.roblox.com/asset/?id=14353037120" or Text3;
            Icon.ScaleType = Enum.ScaleType.Fit;
            
            Index.Name = "";
            Index.Parent = TextBox;
            Index.AnchorPoint = Vector2.new(1, 0.5);
            Index.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Index.BackgroundTransparency = 1;
            Index.BorderSizePixel = 0;
            Index.Position = UDim2.new(1, -5, 0.5, 0);
            Index.Size = UDim2.new(0, 195, 0, 25);
            
            UICorner.Name = "";
            UICorner.Parent = Index;
            UICorner.CornerRadius = UDim.new(0, 4);
            
            UIStroke.Name = "";
            UIStroke.Parent = Index;
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            UIStroke.Color = Color3.fromRGB(0, 0, 0);
            UIStroke.LineJoinMode = Enum.LineJoinMode.Round;
            UIStroke.Thickness = 1;
            UIStroke.Transparency = 1;
            
            Type.Name = "";
            Type.Parent = Index;
            Type.AutomaticSize = Enum.AutomaticSize.X;
            Type.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Type.BackgroundTransparency = 1;
            Type.BorderSizePixel = 0;
            Type.ClipsDescendants = true;
            Type.Position = UDim2.new(0, -4, 0, 2);
            Type.Size = UDim2.new(1, -4, 1, -2);
            Type.Font = Enum.Font.Code;
            Type.LineHeight = 1.2;
            Type.PlaceholderColor3 = Color3.fromRGB(0, 0, 0);
            Type.PlaceholderText = "Type something here";
            Type.Text = StartValue;
            Type.TextColor3 = Color3.fromRGB(0, 0, 0);
            Type.TextSize = 14;
            Type.TextXAlignment = Enum.TextXAlignment.Right;
            
            Frame2.Name = "";
            Frame2.Parent = TextBox;
            Frame2.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
            Frame2.BackgroundTransparency = 1;
            Frame2.BorderSizePixel = 0;
            Frame2.Position = UDim2.new(1, -205, 0, 0);
            Frame2.Size = UDim2.new(0, 1, 1, 0);
            
            ManageSignalsTo("Add", Form("Element.Textbox.%s.%s-Focused", Text1, Text2), Type.Focused:Connect(function()
                Focused = true;
                UIStroke.Transparency = 0.8;
            end));
            ManageSignalsTo("Add", Form("Element.Textbox.%s.%s-FocusLost", Text1, Text2), Type.FocusLost:Connect(function(EnterPressed)
                Focused = false;
                if EnterPressed == true then
                    xpcall(function()
                        Coroutine(function()
                            Function(Type.Text);
                        end);
                    end, function(Message)
                        warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                    end);
                end;
                UIStroke.Transparency = 1;
            end));
            ManageSignalsTo("Add", Form("Element.Textbox.%s.%s-MouseEnter", Text1, Text2), TextBox.MouseEnter:Connect(function()
                UIStroke.Transparency = 0.8;
                TextBox.MouseLeave:Wait();
                if Focused == false then
                    UIStroke.Transparency = 1;
                end;
            end));
            ManageSignalsTo("Add", Form("Element.Textbox.%s.%s-InputBegan", Text1, Text2), Type.InputBegan:Connect(function(Input)
                if Or(string.lower(Input.KeyCode.Name), string.split("abcdefghijklmnopqrstuvwxyz0123456789")) == true then
                    if string.lower(InputType) == "letters" then
                        Type.Text = string.gsub(Type.Text, "%d", "");
                    elseif string.lower(InputType) == "numbers" then
                        Type.Text = (function()
                            local String = "";
                            for Int, Value in pairs(string.split(Type.Text, "")) do
                                if tonumber(Value) == nil then
                                    String = String .. Value;
                                end;
                            end;
                            return String;
                        end)();
                    end;
                end;
            end));
            
            local Service3 = {["Disabled"] = false, ["Title"] = Text1, ["Description"] = Text2, ["Image"] = Text3, ["Text"] = StartValue};
            setmetatable(Service3, {
                __index = function(Table, Key)
                    if Key == "Disabled" then
                        return rawget(Table, Key);
                    elseif Key == "Title" then
                        return Title.Text;
                    elseif Key == "Description" then
                        return Description.Text;
                    elseif Key == "Image" then
                        return Icon.Image;
                    elseif Key == "Text" then
                        return Type.Text;
                    end;
                end,
                __newindex = function(Table, Key, Value)
                    if Key == "Disabled" and typeof(Value) == "boolean" then
                        -- TODO
                        elseif Key == "Title" and typeof(Value) == "string" then
                        Title.Text = Value;
                        elseif Key == "Description" and typeof(Value) == "string" then
                            Description.Text = Value;
                        elseif Key == "Image" and typeof(Value) == "string" then
                            Icon.Image = Value;
                        elseif Key == "Text" and typeof(Value) == "string" then
                            Type.Text = Value;
                        end;
                        rawset(Table, Key, Value);
                end,
            });
            function Service3:CallFunction(...)
                local Arguments = {...};
                xpcall(function()
                    Coroutine(function()
                        Function(table.unpack(Arguments));
                    end);
                end, function(Message)
                    warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                end);
            end;
            function Service3:Remove()
                ManageSignalsTo("Clear", Form("Element.Textbox.%s.%s", Text1, Text2));
                TextBox:Remove();
            end;
            return Service3;
        end;
        function Service2:AddKeybind(Text1, Text2, Text3, BlockedKeys, StartValue, Function)
            Text1 = tostring(Text1) or "INVALID STRING";
            Text2 = tostring(Text2) or "INVALID STRING";
            Text3 = tostring(Text3) or "INVALID STRING";
            BlockedKeys = (typeof(BlockedKeys) == "table" and #BlockedKeys > 0 and BlockedKeys) or {};
            StartValue = (typeof(StartValue) == "Enum" and StartValue.EnumType == Enum.KeyCode and StartValue) or Enum.KeyCode.E;
            Function = (typeof(Function) == "function" and Function) or function() end;
            
            local KeybindValue = StartValue;
            
            local Keybind = Instance.new("ImageButton");
            local Frame = Instance.new("Frame");
            local Title = Instance.new("TextLabel");
            local Description = Instance.new("TextLabel");
            local Icon = Instance.new("ImageLabel");
            local KeybindLabel = Instance.new("TextLabel");
            
            Keybind.Name = "Keybind";
            Keybind.Parent = Container;
            Keybind.Active = false;
            Keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Keybind.BackgroundTransparency = 1;
            Keybind.Selectable = false;
            Keybind.Size = UDim2.new(1, 0, 0, 40);
            Keybind.AutoButtonColor = false;
            
            Frame.Name = "";
            Frame.Parent = Keybind;
            Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
            Frame.BackgroundTransparency = 0.9;
            Frame.BorderSizePixel = 0;
            Frame.Position = UDim2.new(0, 0, 1, 0);
            Frame.Size = UDim2.new(1, 0, 0, 1);
            
            Title.Name = "Title";
            Title.Parent = Keybind;
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Title.BackgroundTransparency = 1;
            Title.BorderSizePixel = 0;
            Title.Position = UDim2.new(0, 40, 0, 4);
            Title.Size = UDim2.new(1, -155, 0.5, 0);
            Title.Font = Enum.Font.SourceSans;
            Title.Text = Text1;
            Title.TextColor3 = Color3.fromRGB(255, 255, 255);
            Title.TextSize = 17;
            Title.TextXAlignment = Enum.TextXAlignment.Left;
            Title.TextYAlignment = Enum.TextYAlignment.Top;
            
            Description.Name = "Description";
            Description.Parent = Keybind;
            Description.AnchorPoint = Vector2.new(0, 1);
            Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Description.BackgroundTransparency = 1;
            Description.BorderSizePixel = 0;
            Description.Position = UDim2.new(0, 40, 1, -4);
            Description.Size = UDim2.new(1, -155, 0.5, 0);
            Description.Font = Enum.Font.SourceSans;
            Description.Text = Text2;
            Description.TextColor3 = Color3.fromRGB(255, 255, 255);
            Description.TextSize = 15;
            Description.TextTransparency = 0.3;
            Description.TextXAlignment = Enum.TextXAlignment.Left;
            Description.TextYAlignment = Enum.TextYAlignment.Bottom;
            
            Icon.Name = "Icon";
            Icon.Parent = Keybind;
            Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            Icon.BackgroundTransparency = 1;
            Icon.BorderSizePixel = 0;
            Icon.Position = UDim2.new(0, 5, 0, 5);
            Icon.Size = UDim2.new(0, 30, 0, 30);
            Icon.Image = Text3 == "" and "http://www.roblox.com/asset/?id=14353037120" or Text3;
            Icon.ScaleType = Enum.ScaleType.Fit;
            
            KeybindLabel.Name = "Key";
            KeybindLabel.Parent = Keybind;
            KeybindLabel.AnchorPoint = Vector2.new(1, 0.5);
            KeybindLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            KeybindLabel.BackgroundTransparency = 1;
            KeybindLabel.BorderSizePixel = 0;
            KeybindLabel.Position = UDim2.new(1, -10, 0.5, 0);
            KeybindLabel.Size = UDim2.new(0, 100, 0.5, 0);
            KeybindLabel.Font = Enum.Font.SourceSansBold;
            KeybindLabel.LineHeight = 1.1;
            KeybindLabel.Text = string.upper(StartValue.Name);
            KeybindLabel.TextColor3 = Color3.fromRGB(0, 0, 0);
            KeybindLabel.TextSize = 15;
            KeybindLabel.TextTransparency = 0.3;
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Right;
            
            ManageSignalsTo("Add", Form("Element.Keybind.%s.%s-MouseButton1Click", Text1, Text2), Keybind.MouseButton1Click:Connect(function()
                KeybindLabel.Text = "...";
                Coroutine(function()
                    local InputWait = UserInputService.InputBegan:Wait();
                    if InputWait.KeyCode ~= Enum.KeyCode.Unknown then
                        KeybindLabel.Text = string.upper(InputWait.KeyCode.Name);
                        KeybindValue = InputWait.KeyCode;
                    end;
                end);
            end));
            ManageSignalsTo("Add", Form("Element.Keybind.%s.%s-InputBegan", Text1, Text2), UserInputService.InputBegan:Connect(function(Input, Processed)
                if Processed == false and Input.KeyCode == KeybindValue then
                    xpcall(function()
                        Coroutine(function()
                            Function(Input.KeyCode);
                        end);
                    end, function(Message)
                        warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                    end);
                end;
            end));
            
            local Service3 = {["Disabled"] = false, ["Title"] = Text1, ["Description"] = Text2, ["Image"] = Text3, ["Keybind"] = StartValue, ["BlockedKeys"] = BlockedKeys};
            setmetatable(Service3, {
                __index = function(Table, Key)
                    if Key == "Disabled" then
                        return rawget(Table, Key);
                    elseif Key == "Title" then
                        return Title.Text;
                    elseif Key == "Description" then
                        return Description.Text;
                    elseif Key == "Image" then
                        return Icon.Image;
                    elseif Key == "Keybind" then
                        return rawget(Table, "Keybind");
                    elseif Key == "BlockedKeys" then
                        return rawget(Table, "BlockedKeys");
                    end;
                    return nil;
                end,
                __newindex = function(Table, Key, Value)
                    if Or(Key, {"Disabled", "Title", "Description", "Image", "Keybind", "BlockedKeys"}) == true then
                        if Key == "Disabled" and typeof(Value) == "boolean" then
                            rawset(Table, Key, Value);
                        -- TODO
                        elseif Key == "Title" and typeof(Value) == "string" then
                            rawset(Table, Key, Value);
                            Title.Text = Value;
                        elseif Key == "Description" and typeof(Value) == "string" then
                            rawset(Table, Key, Value);
                            Description.Text = Value;
                        elseif Key == "Image" and typeof(Value) == "string" then
                            rawset(Table, Key, Value);
                            Icon.Image = Value;
                        elseif Key == "Keybind" and typeof(Value) == "Enum" then
                            if Value.EnumType == Enum.KeyCode then
                                rawset(Table, Key, Value);
                                KeybindLabel.Text = string.upper(Value.Name);
                                KeybindValue = Value;
                            end;
                        elseif Key == "BlockedKeys" then
                            rawset(Table, Key, Value);
                        end;
                    end;
                end,
            });
            function Service3:CallFunction(...)
                local Arguments = {...};
                xpcall(function()
                    Coroutine(function()
                        Function(table.unpack(Arguments));
                    end);
                end, function(Message)
                    warn(Form("\nQUEX PROJECTS\n      Library\n%s", Message));
                end);
            end;
            function Service3:Remove()
                ManageSignalsTo("Clear", Form("Element.Keybind.%s.%s", Text1, Text2));
                Keybind:Remove();
            end;
            return Service3;
        end;
        function Service2:ChangeTitleTo(Text)
            Title.Text = Text;
        end;
        function Service2:ClearChildren()
        end;
        function Service2:Remove()
        end;
        return Service2;
    end;
    function Service1:OpenTab(Title)
        if Containers:FindFirstChild(Title) ~= nil then
            local Selection = SelectionContainer[Title];
            local Frame = Selection:FindFirstChildOfClass("Frame");
            repeat wait() until Frame:FindFirstChildOfClass("UIStroke") ~= nil;
            Containers:FindFirstChild(Title).Visible = true;
            Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
            Frame.BackgroundTransparency = 1;
            Frame:FindFirstChildOfClass("UIStroke").Color = GuiBorderColor == Color3.fromRGB(0, 0, 0) and Color3.fromRGB(84, 255, 241) or GuiBorderColor;
            Selection.Label.TextColor3 = GuiBorderColor == Color3.fromRGB(0, 0, 0) and Color3.fromRGB(84, 255, 241) or GuiBorderColor;
            for Int, Value in pairs(Containers:GetChildren()) do
                if Value.ClassName == "ScrollingFrame" and Value ~= Containers:FindFirstChild(Title) then
                    local Selection = SelectionContainer[Value.Name];
                    local Frame = Selection:FindFirstChildOfClass("Frame");
                    Value.Visible = false;
                    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
                    Frame.BackgroundTransparency = 0.8;
                    Frame:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(0, 0, 0);
                    Selection.Label.TextColor3 = Color3.fromRGB(255, 255, 255);
                end;
            end;
        end;
    end;
    function Service1:Close()
        ManageSignalsTo("Clear");
        GuiClosed = true;
        Library:Remove();
        Coroutine(function()
            OnCloseCallback();
        end);
    end;
    function Genv.Close()
        ManageSignalsTo("Clear");
        GuiClosed = true;
        Library:Remove();
    end;
    return Service1;
end;
