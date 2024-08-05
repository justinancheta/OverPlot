classdef OverPlot < matlab.apps.AppBase
%   
%   ABOUT: Simple utility to quickly plot up images. Log plotting has not
%   been tested but should work based on how GetPoints works.
%
%   Syntax: OverPlot(x,y)
%           Where X and Y are equal sized Nx1 (or 1xN) vectors, or pair
%           wise cell arrays of Vectors X = {X1, X2, X3}, Y = {Y1, Y2, Y3}
%           to plot X1,Y1 and X2,Y2 ....
%
%   Notes:
%   [1] To append legends or make plots prettier send to workspace / figure
%   file and modify from there. This is just the quick plotting script. 
% 
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        FileEditField         matlab.ui.control.EditField
        OpenFileButton        matlab.ui.control.Button
        XRangeEditFieldLabel  matlab.ui.control.Label
        XRangeEditField       matlab.ui.control.NumericEditField
        YRangeEditFieldLabel  matlab.ui.control.Label
        YRangeEditField       matlab.ui.control.NumericEditField
        XMaxEditField         matlab.ui.control.NumericEditField
        YMaxEditField         matlab.ui.control.NumericEditField
        XLogSwitchLabel       matlab.ui.control.Label
        XLogSwitch            matlab.ui.control.Switch
        YLogSwitchLabel       matlab.ui.control.Label
        YLogSwitch            matlab.ui.control.Switch
        ControlPointsButton   matlab.ui.control.Button
        WritetoFileButton     matlab.ui.control.Button
        ToggleConPtsButton    matlab.ui.control.Button
        ToWorkspaceButton     matlab.ui.control.Button
    end


    properties (Access = private)
        fileName % This is the filename that will be used to open an image
        XMin     % Minimum value of x for plot
        XMax     % Maximum value of x for plot
        YMin     % Minimum value of y for plot
        YMax     % Maximum value of y for plot
        xc_p     % Control points for plot (X)
        yc_p     % Control points for plot (Y)
        x        % Store the points x values
        y        % Store the points y values 
        XLog     % Toggle X axis logarithmic functions 
        YLog     % Toggle Y axis logarithmic functions 
        x_p      % Store the selected points x values 
        y_p      % Store the selected points y values 
        img      % Holds the image
        hndl     % Figure handle that supports regular figure callbacks (not UIFigure)
        ax       % Axes handle for figure;
        % Annotations for figure
        sc_p     % Scatter object for control points 
        l_p      % Line object for display points
        colors   % Color Library
    end

    methods (Access = private)
    
        function updatePlot(app)
            % Call to update primary plot
            if ~isempty(app.l_p)
                delete(findobj(gca,'type','line'));
            end
            ColorCounter = 1;
            LineCounter  = 1;
            lineStyles = {'-','--','-.',':'};
            for ii = 1:numel(app.x) 
                if app.XLog
                    app.x_p{ii} = app.xc_p(1) + ( app.x{ii} - log10(app.XMin) ) * (app.xc_p(2) - app.xc_p(1)) / (log10(app.XMax) - log10(app.XMin));
                else
                    app.x_p{ii} = app.xc_p(1) + ( app.x{ii} - app.XMin ) * (app.xc_p(2) - app.xc_p(1)) / (app.XMax - app.XMin)  ;
                end

                if app.YLog
                    app.y_p{ii} = app.yc_p(1) + ( app.y{ii} - log10(app.YMin) ) * (app.yc_p(4) - app.yc_p(1)) / (log10(app.YMax) - log10(app.YMin));
                else
                    app.y_p{ii} = app.yc_p(1) + ( app.y{ii} - app.YMin ) * (app.yc_p(4) - app.yc_p(1)) / (app.YMax - app.YMin)  ;
                end
                
                % Add line to plot 
                app.l_p{ii} = plot(app.ax, app.x_p{ii}, app.y_p{ii},'Color',app.colors(ColorCounter,:), 'LineStyle', lineStyles{LineCounter});
%                 app.l_p{ii} = plot(app.ax, app.x_p{ii}, app.y_p{ii});

                ColorCounter = ColorCounter + 1;
                % If we exceed the iterator swap line styles
                if ColorCounter == 10
                    ColorCounter = 1;
                    LineCounter = LineCounter + 1;
                    % If we overflow the lines we reset the line style ( why do you have this many lines... )
                    if LineCounter == 5
                        LineCounter = 1;
                    end
                end
            end
        end
        
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Basic initialization values 
            app.fileName = 'Click on the button to open an image';
            app.XMin = 0;
            app.XMax = 1;
            app.YMin = 0;
            app.YMax = 1;
            app.XLog = false;
            app.YLog = false;
            
            % Set Basic Color options
            app.colors = [  [230 025 075]; % Distinct Red
                            [060 180 075]; % Distinct Green
                            [000 130 200]; % Distinct Blue
                            [245 130 048]; % Distinct Orange
                            [240 050 230]; % Distinct Magenta
                            [070 240 240]; % Distinct Cyan
                            [170 110 040]; % Distinct Brown
                            [000 128 128]; % Distinct Teal
                            [220 190 255]; % Distinct Lavendar
                         ]/255;
            
            % Update fields after startup creation
            app.FileEditField.Value = app.fileName;
            
            % Display instructions at the begining 
                msgbox({"Select axes control points in order of [X0,Y0], [X1, Y0], [X1, Y1], [X0,Y1] (ccw from origin)";...
                    "";...
                    "To update the legend, save figure to file or workspace and modify from the figure handle"});
        end

        % Button pushed function: ControlPointsButton
        function ControlPointsButtonPushed(app, event)
            % Remove current control poitns if they exist 
            if ~isempty(app.sc_p)
                delete(findobj(gca,'type','scatter'));
            end
            
            % Get the control points 
            [app.xc_p,app.yc_p] = ginput(4);
            hold on;
            
            % Plot control points 
            app.sc_p = scatter(app.ax, app.xc_p, app.yc_p,'MarkerEdgeColor','k','MarkerFaceColor','k');
                        
            % Generate the image x/y values to plot
            app.updatePlot();
            
            % Enable the toggle buttons and write to file buttons 
            app.ToggleConPtsButton.Enable = 'on';
            app.WritetoFileButton.Enable = 'on';
            app.ToWorkspaceButton.Enable = 'on';
        end

        % Value changed function: FileEditField
        function FileEditFieldValueChanged(app, event)
            value = app.FileEditField.Value;
            app.fileName = value;
        end

        % Button pushed function: OpenFileButton
        function OpenFileButtonPushed(app, event)
            [file,location] = uigetfile( ...
                                        {'*.png', 'PNG Files (*.png)';
                                          '*.jpeg;.jpg', 'JPEG Files (*.jpg, *.jpeg)';
                                          '*.*',  'All Files (*.*)'}, ...
                                           'Select a File');
            app.fileName = [location, file];
            app.FileEditField.Value = app.fileName;
            app.img = imread(app.fileName);
            app.hndl = figure;
            app.ax = gca;
            imshow(app.img, 'Parent', app.ax, 'InitialMagnification','fit');
            
            % Enable the buttons that do plotting things 
            app.ControlPointsButton.Enable = 'on';
            app.XLogSwitch.Enable = 'on';
            app.YLogSwitch.Enable = 'on';
            app.XRangeEditField.Enable = 'on';
            app.YRangeEditField.Enable = 'on';
            app.XMaxEditField.Enable = 'on';
            app.YMaxEditField.Enable = 'on';
        end

        % Button pushed function: ToggleConPtsButton
        function ToggleConPtsButtonPushed(app, event)
            % Just hide the control points after everything looks aligned for saving off figures
            if strcmpi(app.sc_p.Marker,'none')
                app.sc_p.Marker = 'o';
            else
                app.sc_p.Marker = 'none';
            end
        end

        % Button pushed function: WritetoFileButton
        function WritetoFileButtonPushed(app, event)
            % Get text input from matlab window
            vname = inputdlg({'Enter output file name:'}, 'Input', [1 260], {'defaultOutputName'});
            
            [path,name,ext]= fileparts(vname{1});
            
            % Try to put the file path together            
            if and(isempty(path), isempty(ext))
                outName = ['./',name,'.fig'];
                fprintf('No path was entered, assuming current working directory\n.')
            elseif and(isempty(path), ~isempty(ext))
                outName = ['./',name];
                fprintf('No path was entered, assuming current working directory\n.')
            else
                % At this point its on the user im not doing error checking 
                outName = name;
            end
            
            % Use the java io to verify the file is writeable
            writefile = true;
            try
                java.io.File(outName).toPath;
            catch
                writefile = false;
                fprintf('The input file name is not able to be used as a file, no output was attempted.\n')
            end
            
            if writefile
                saveas(app.ax, outName);
            end
        end

        % Value changed function: XLogSwitch
        function XLogSwitchValueChanged(app, event)
            switch app.XLogSwitch.Value
                case 'On'
                    app.XLog = true;
                case 'Off'
                    app.XLog = false;
            end
            app.updatePlot();
        end

        % Value changed function: XMaxEditField
        function XMaxEditFieldValueChanged(app, event)
            value = app.XMaxEditField.Value;
            app.XMax = value;
            if app.XMax <= app.XMin
                app.XMax = app.XMin + 1;
                app.XMaxEditField.Value = app.XMin + 1;
            end
            app.updatePlot();
        end

        % Value changed function: XRangeEditField
        function XRangeEditFieldValueChanged(app, event)
            value = app.XRangeEditField.Value;
            app.XMin = value;
            if app.XMin >= app.XMax
                app.XMin = app.XMax - 1;
                app.XRangeEditField.Value = app.XMax - 1;
            end
            app.updatePlot();
        end

        % Value changed function: YLogSwitch
        function YLogSwitchValueChanged(app, event)
            switch app.YLogSwitch.Value
                case 'On'
                    app.YLog = true;
                case 'Off'
                    app.YLog = false;
            end
            app.updatePlot();
        end

        % Value changed function: YMaxEditField
        function YMaxEditFieldValueChanged(app, event)
            value = app.YMaxEditField.Value;
            app.YMax = value;
            if app.YMax <= app.YMin
                app.YMax = app.YMin + 1;
                app.YMaxEditField.Value = app.YMin + 1;
            end
            app.updatePlot();
        end

        % Value changed function: YRangeEditField
        function YRangeEditFieldValueChanged(app, event)
            value = app.YRangeEditField.Value;
            app.YMin = value;
            if app.YMin >= app.YMax
                app.YMin = app.YMax - 1;
                app.YRangeEditField.Value = app.YMax - 1;
            end
            app.updatePlot();
        end

        % Button pushed function: ToWorkspaceButton
        function ToWorkspaceButtonPushed(app, event)
            % Get text input from matlab window
            vname = inputdlg({'Enter variable name:'}, 'Input', [1 45], {'defaultOutputName'});
            % Remove the control points since they are uncessary 
            if ~isempty(app.sc_p)
                delete(findobj(gca,'type','scatter'));
            end
            % Verify its a valid name, otherwise convert it
            if ~isvarname(vname{1})
                outName = matlab.lang.makeValidName(vname{1});
                sprintf('Variable %s was not valid, renamed to %s', vname{1}, outName);
            else
                outName = vname{1};
            end
            
            assignin('base', outName, app.hndl);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 100 733 159];
            app.UIFigure.Name = 'UI Figure';

            % Create FileEditField
            app.FileEditField = uieditfield(app.UIFigure, 'text');
            app.FileEditField.ValueChangedFcn = createCallbackFcn(app, @FileEditFieldValueChanged, true);
            app.FileEditField.Position = [172 21 413 22];

            % Create OpenFileButton
            app.OpenFileButton = uibutton(app.UIFigure, 'push');
            app.OpenFileButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFileButtonPushed, true);
            app.OpenFileButton.Position = [42 21 100 22];
            app.OpenFileButton.Text = 'Open File';

            % Create XRangeEditFieldLabel
            app.XRangeEditFieldLabel = uilabel(app.UIFigure);
            app.XRangeEditFieldLabel.HorizontalAlignment = 'right';
            app.XRangeEditFieldLabel.Enable = 'off';
            app.XRangeEditFieldLabel.Position = [43 112 53 15];
            app.XRangeEditFieldLabel.Text = 'X Range';

            % Create XRangeEditField
            app.XRangeEditField = uieditfield(app.UIFigure, 'numeric');
            app.XRangeEditField.ValueChangedFcn = createCallbackFcn(app, @XRangeEditFieldValueChanged, true);
            app.XRangeEditField.ValueDisplayFormat = '%.10G';
            app.XRangeEditField.Enable = 'off';
            app.XRangeEditField.Position = [110 108 100 22];

            % Create YRangeEditFieldLabel
            app.YRangeEditFieldLabel = uilabel(app.UIFigure);
            app.YRangeEditFieldLabel.HorizontalAlignment = 'right';
            app.YRangeEditFieldLabel.Enable = 'off';
            app.YRangeEditFieldLabel.Position = [44 72 53 15];
            app.YRangeEditFieldLabel.Text = 'Y Range';

            % Create YRangeEditField
            app.YRangeEditField = uieditfield(app.UIFigure, 'numeric');
            app.YRangeEditField.ValueChangedFcn = createCallbackFcn(app, @YRangeEditFieldValueChanged, true);
            app.YRangeEditField.ValueDisplayFormat = '%.10G';
            app.YRangeEditField.Enable = 'off';
            app.YRangeEditField.Position = [110 69 100 22];

            % Create XMaxEditField
            app.XMaxEditField = uieditfield(app.UIFigure, 'numeric');
            app.XMaxEditField.ValueChangedFcn = createCallbackFcn(app, @XMaxEditFieldValueChanged, true);
            app.XMaxEditField.ValueDisplayFormat = '%.10G';
            app.XMaxEditField.Enable = 'off';
            app.XMaxEditField.Position = [222 108 100 22];
            app.XMaxEditField.Value = 1;

            % Create YMaxEditField
            app.YMaxEditField = uieditfield(app.UIFigure, 'numeric');
            app.YMaxEditField.ValueChangedFcn = createCallbackFcn(app, @YMaxEditFieldValueChanged, true);
            app.YMaxEditField.ValueDisplayFormat = '%.10G';
            app.YMaxEditField.Enable = 'off';
            app.YMaxEditField.Position = [222 69 100 22];
            app.YMaxEditField.Value = 1;

            % Create XLogSwitchLabel
            app.XLogSwitchLabel = uilabel(app.UIFigure);
            app.XLogSwitchLabel.HorizontalAlignment = 'center';
            app.XLogSwitchLabel.Enable = 'off';
            app.XLogSwitchLabel.Position = [360.5 77 38 15];
            app.XLogSwitchLabel.Text = 'X-Log';

            % Create XLogSwitch
            app.XLogSwitch = uiswitch(app.UIFigure, 'slider');
            app.XLogSwitch.ValueChangedFcn = createCallbackFcn(app, @XLogSwitchValueChanged, true);
            app.XLogSwitch.Enable = 'off';
            app.XLogSwitch.Position = [357 107 45 20];

            % Create YLogSwitchLabel
            app.YLogSwitchLabel = uilabel(app.UIFigure);
            app.YLogSwitchLabel.HorizontalAlignment = 'center';
            app.YLogSwitchLabel.Enable = 'off';
            app.YLogSwitchLabel.Position = [471 79 37 15];
            app.YLogSwitchLabel.Text = 'Y-Log';

            % Create YLogSwitch
            app.YLogSwitch = uiswitch(app.UIFigure, 'slider');
            app.YLogSwitch.ValueChangedFcn = createCallbackFcn(app, @YLogSwitchValueChanged, true);
            app.YLogSwitch.Enable = 'off';
            app.YLogSwitch.Position = [467 106 45 20];

            % Create ControlPointsButton
            app.ControlPointsButton = uibutton(app.UIFigure, 'push');
            app.ControlPointsButton.ButtonPushedFcn = createCallbackFcn(app, @ControlPointsButtonPushed, true);
            app.ControlPointsButton.Enable = 'off';
            app.ControlPointsButton.Position = [596 117 100 22];
            app.ControlPointsButton.Text = 'Control Points';

            % Create WritetoFileButton
            app.WritetoFileButton = uibutton(app.UIFigure, 'push');
            app.WritetoFileButton.ButtonPushedFcn = createCallbackFcn(app, @WritetoFileButtonPushed, true);
            app.WritetoFileButton.Enable = 'off';
            app.WritetoFileButton.Position = [596.5 21 100 22];
            app.WritetoFileButton.Text = 'Write to File';

            % Create ToggleConPtsButton
            app.ToggleConPtsButton = uibutton(app.UIFigure, 'push');
            app.ToggleConPtsButton.ButtonPushedFcn = createCallbackFcn(app, @ToggleConPtsButtonPushed, true);
            app.ToggleConPtsButton.Enable = 'off';
            app.ToggleConPtsButton.Position = [596 85 100 22];
            app.ToggleConPtsButton.Text = 'Toggle Con Pts';

            % Create ToWorkspaceButton
            app.ToWorkspaceButton = uibutton(app.UIFigure, 'push');
            app.ToWorkspaceButton.ButtonPushedFcn = createCallbackFcn(app, @ToWorkspaceButtonPushed, true);
            app.ToWorkspaceButton.Enable = 'off';
            app.ToWorkspaceButton.Position = [596.5 53 100 22];
            app.ToWorkspaceButton.Text = 'To Workspace';
        end
    end

    methods (Access = public)

        % Construct app
        function app = OverPlot(x,y)

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            % Assign data to cells if numeric then pass to app. This is to
            % allow plotting multiple lines on same line 
            if isnumeric(x)
                x = {x};
            end
            
            if isnumeric(y)
                y = {y};
            end
            
            app.x = x;
            app.y = y;
            
            
            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end