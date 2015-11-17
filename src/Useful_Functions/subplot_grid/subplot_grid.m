classdef subplot_grid < handle
    
    properties
        current_axes = [1,1]
        nof_rows
        nof_columns
        mergelist
        hfig
        hax
        htitle
        hsubtitle
        hrowtitles
        hcoltitles
        hlegend
        subplotzoom_enabled
        interaxes_selection_mods = struct('LineWidth',2,...
            'LineStyle','-')
        legend_data
        loose_inset_px = 5*ones(1,4);
        subplotzoom_data
        hcolorbar;
    end
    
    properties(Access=private)
        hax_figtitle
        hax_subfigtitle
        hax_coltitles
        hax_rowtitles
        zoom_button_size_x = 10;
        zoom_button_size_y = 10;
        zoomed
        hidden_axes = [];
        interaxes_data = struct([]);
        interaxes_supported_types = {'line';
            'image';
            'surface';
            };
        viewer = struct('nof_minor_rows',0,...
            'starting_index',0);
        legend_data_struct = struct('elmspecs',[],...
            'textlines',[],...
            'location','northeast',...
            'orientation',[],...
            'print_legend_title',0,...
            'position',[],...
            'axes_reduction',[]);
        loose_inset_px_default = 5*ones(1,4);
        
    end
    
    events
        
    end
    
    methods
        
        function this = subplot_grid(nr,nc,varargin)
            
            % SUBPLOT_GRID generates a figure containing the number of subplots
            %   wanted. Subplots can be merged through a variable input parameters.
            %
            %   This function creates a subplot layout such that the OuterPosition of
            %   every subplot axes is maximized for this figure.
            %
            %   Resizing the figure automatically corrects the maximization process,
            %   and keeps the figure title, and possibly column and row titles as
            %   minimal as possible, thus maintaining the maximum amount of space for
            %   the subplots
            %
            %   For a demo of the class use: subplot_grid or subplot_grid.demo
            %
            %   For the automated creation of a 'viewer' mode figure, use
            %   subplot_grid('viewer',nof_figures,VARARGIN).
            %   The VARARGIN parameters are 1. number of rows for minor plots, 2.
            %   postion of minor plots (i.e., 'top' or 'bottom' (=default))
            %
            %   A simple one-parameter call of subplot_grid makes subplot_grid
            %   calculate the optimal layout itself. Call 'subplot_grid(nof_figures)'
            %   for this feature.
            %
            % SYNTAX:
            %   obj = subplot_grid(nr,nc,varargin)
            %
            % INPUT PARAMETERS:
            %   nr [int] The number of rows containing subplots
            %   nc [int] The number of columns containing subplots
            %
            % VARARGIN PARAMETERS:
            %   1:  [cell] Cell array of vectors. Every vector contains the subplot
            %              indices. The subplots to merge are the subplots in the
            %              rectangle spanning all subplots indices in the vector. A 2D
            %              vector is therefore sufficient to merge multiple subplots
            %
            % PROPERTIES:
            %   nof_rows              Nof rows in subplot grid
            %   nof_columns           Nof columns in subplot grid
            %   mergelist             Merge list for subplot grid (see above)
            %   hfig                  Handle of figure
            %   hax                   The matrix with the same shape as the subplot
            %                         layout of the figure, containing the handles to
            %                         the subplots created.
            %   htitle                The handle to the figure titles textbox.
            %   hrowtitles            The handles to the row titles textboxes. The order is
            %                         from top to bottom (i.e., the normal row count order)
            %   hcoltitles            The handles to the column titles textboxes. The
            %                         counting order is from left to right.
            %   subplotzoom_enabled  Enable/disable subplotzoom functionality.
            %                         0 = disable subplotzoom
            %                         1 = enable subplotzoom (Default)
            %   interaxes_selection_mods
            %                         Properties to modify when a graphics object is
            %                         selected. Examples are 'LineWidth' and 'Color'.
            %                         Only properties which exist for a specific object
            %                         are modified.
            %
            % USER METHODS:
            %   figtitle              Adds a figure title above the subplots
            %   subfigtitle           Adds a subtitle to the figure.
            %   coltitle              (obsolete) Adds column titles above every column
            %   rowtitle              (obsolete) Adds row titles to the left of every row.
            %   coltitles             Adds column titles above every column
            %   rowtitles             Adds row titles to the left of every row.
            %   set_gca               Set the actual axis as current axes for that
            %                         figure
            %   disable_subplotzoom   Disable the subplot zoom
            %   enable_subplotzoom    Enable the subplot zoom
            %   hide_axes             Hides an axes (by default all subplots are
            %                         generated
            %   show_axes             Shows an axes which has been hidden before.
            %   enable_interaxes      Enable the interaxes functionality in which the
            %                         axes become clickable (implemented for
            %                         'line','surface' and 'image' graphical objects)
            %   disable_interaxes     Disables the interaxes functionality
            %   overwrite_interaxes_selection_mods
            %                         Overwrites the default selection modifications
            %                         per axes.
            %   hide_empty_axes       Hides all axes which do not contain any graphical
            %                         content/objects.
            %   legend                creates a legend without connection to content.
            %   relocate_legend       re-locates the legend of a specific subplot to a
            %                         given location
            %   remove_legend         Removes the legends from one or multiple
            %                         subplots
            %   x_sync_axes           The x axis range of a number of axes can be
            %                         synchronized to a selected master axes.
            %
            % OUTPUT PARAMETER:
            %   Object of type 'subplot_grid'
            %
            % MODIFICATIONS:
            % <pre release>
            %   20101206  : (Joris) Fixed a bug in the ordering of row and column
            %                       titles in the subfunction 'subplot_resize_fcn'.
            %   20101208  : (Joris) Fixed a bug regarding the resizing of plots that
            %                       have colorbars.
            %   20101210 : (Benno) Modified the function to class, and
            %                      added subplotzoom functionality.
            %   20101213 : (Joris) Modified and cleaned up class code.
            %   20101213 : (Joris) Fixed bug in resizing while zoomed-out.
            %   20101214 : (Joris) Added 'extract_axes' function which creates a new
            %                      figure in which the wanted axes contents are copied.
            %   20101218 : (Joris) Added 'interaxes' function which enables the use of
            %                      the mouse click and arrow buttons for navigation
            %                      through the axis. To be set.
            %   20101218 : (Joris) Fixed a bug regarding the placement after addition
            %                      of row titles.
            %   20101222 : (Joris) Some minor bugfixes and addition of the maintainance
            %                      of the interaxes function after the
            %                      'extract_subplot' command.
            % <<==== version 1.0 created ====>>
            %   20110103 : (Joris) Bugfix: interaxes functionality did not correctly
            %                      function after 'extract_axes' method.
            %   20110103 : (Joris) Bugfix: method 'disable_interaxes' gave errors
            % <<=== version 1.1 created ===>>
            %   20110104 : (Joris) Bugfix: resizing with no row and/or column titles
            %                      gave an error.
            % <<=== version 1.2 created ==>>
            %   20110106 : (Joris) Added the moving to the top of the plot object stack
            %                      when zoomed via subplotzoom.
            %   20110106 : (Joris) Bugfix: adding column titles when Nr != Nc crashed
            % <<=== version 1.3 created ==>>
            %   20110118 : (Joris) Naming update: changed property 'hax_subplots' to 'hax'.
            %                      Naming update: changed method 'set_actual_subplot'
            %                      to 'set_gca'
            % <<=== version 1.4 created ===>>
            %   20110201 : (Joris) Added methods 'show_axes' and 'hide_axes', which
            %                      control the visibility of any of the subplot axes
            %                      created by default at instantiation of this class.
            % <<=== version 1.5 created ==>>
            %   20110201 : (Joris) Bugfix: when using 'hide_axes' and zooming via the
            %                     subplotzoom callback. On zooming back out to the
            %                     orginal axes position, the hidden axes appears. This
            %                     is fixed.
            % <<=== version 1.6 created ==>>
            %   20110203 : (Joris) Adding the method 'hide_empty_axes' which hide all
            %                      axes that do not contain any graphical objects.
            %   20110207 : (Joris) Added the possibility to use a subplot index instead
            %                      of only the row and column indices. Numbering is
            %                      equal to the matlab SUBPLOT function indexing.
            %   20110207 : (Joris) Added the possibility for most methods to give a
            %                      set of axes as parameters which will be looped.
            %   20110207 : (Joris) Bugfix: disabling and enabling INTERAXES for a set
            %                      of axes did not function properly.
            %   20110207 : (Joris) Added the possibility to enable and disable
            %                      SUBPLOTZOOM for a subset of all axes.
            %                      subset of axes.
            %   20110207 : (Joris) Added help data for all methods
            % <<=== version 2.0 created ===>>
            %   20110214 : (Joris) Modified subplot_grid to function correctly during
            %                      saving and loading the figure. A function
            %                      'reset_handles' is added. When loading, and the
            %                      resize function cannot find the handles specifies,
            %                      it calls this reset_handles function
            %   20110310 : (Joris) Added the 'viewer' mode. This is a major subplot and
            %                      a row of minor subplots. Easy to use for one
            %                      combined plot, and several individual plots.
            %   20110310 : (Joris) Added the possibility for single-parameter usage.
            %                      This calculates the number of rows and columns itself.
            % <<=== version 3.0 created ===>>
            %   20110526 : (Joris) Added the possibility to add a subtitle to the
            %                      figure.
            %   20110804 : (Joris) Added the methods ROWTITLES and COLTITLES for a more
            %                      intuitive feel, since there are multiple rows and
            %                      columns which are to be titled.
            %   20111130 : (Joris) Added the possibility to add a fixed legend
            %                      (predefined), not necessarily related to actual
            %                      content. Use method LEGEND to create this. Re
            %                      locating can be done with the method PLACE_LEGEND
            % <<=== version 4.0 created ===>>
            %   20111206 : (Joris) Added the possibility to place a legend 'outside'
            %                      the axes and auto-scaling the axes. Resizing and
            %                      zooming functions work also for legends placed
            %                      outside the axes.
            %   20111206 : (Joris) Added the methods RELOCATE_LEGEND and REMOVE_LEGEND
            %                      in this class. See their respective help functions
            %                      for more information on syntax.
            % <<=== version 4.1 created ===>>
            %   20111208 : (Joris) Set 'LooseInset' property of all axes to a fixed
            %                      width. See property 'loose_inset_px' for the values.
            %   20111213 : (Joris) Cleaned up code, and fixed some warnings. In the
            %                      process fixed some small bugs (although there are
            %                      without a doubt some left).
            %   20111213 : (Joris) Extended the demo (call SUBPLOT_GRID) to incorporate
            %                      some zooming, legend creation and interaxes
            %                      functionality.
            % <<=== version 4.2 created ===>>
            %   20111219 : (Joris) Extended the LEGEND method to be able to handle
            %                      all plot properties. See help of LEGEND method for
            %                      more information.
            % <<=== version 4.3 created ===>>
            %   20120101 : (Joris) in the LEGEND method, changed the number of markers
            %                      from 3 to a single marker in the centre of the line,
            %                      to mimic the MATLAB-style legend
            %   20120117 : (Benno) Added x_sync_axes to synchronise axes x.
            %                      TODO: - Link Y, link both, unlink
            %                            - Add consistency checks
            %   20120302 : (Joris) Bugfix in the placement of the legend
            %                      using SUBPLOTZOOM to enlarge and
            %                      contract again.
            %   20120302 : (Joris) Added functionality to correctly handle
            %                      the deletion/closing of axes or clearing
            %                      the figure. Also on resizing.
            %   20120302 : (Joris) Bugfix in the zooming of an axes with legends on other 
            %                      axes. The axes with legends did not recover correctly 
            %   20120302 : (Joris) Added COLORBAR method to add a colorbar
            %                      with the same inputs as the normal
            %                      MATLAB colorbar function.
            %   20120302 : (Joris) Added method SET_PADDING which allows
            %                      control over the amount of whitespace
            %                      between axes (Default: [5,5,5,5] pixels) 
            
            % <<=== version 4.4 created ===>
            %
            % KNOWN LIMITATIONS:
            %   20120203 : (joris) The MATLAB function PLOTYY does not work
            %                      correctly with subplot_grid, because of the
            %                      fact that PLOTYY uses two overlaying
            %                      axes; one with an y-axis on the left,
            %                      and one with an y-axes on the right.
            %
            % ABOUT:
            %   Birthdate: december 6, 2010
            %   Authors: Joris Kampman/Benno Schl�nsen,
            %
            
            
            %% VARARGIN inputs
            %%------------------------------------------------------------------------
            if nargin == 0 || strcmpi(nr,'demo'), % demo
                this.demo
                return
            end
            
            if strcmpi(nr,'viewer'),
                nof_figures = nc;
                mode = 'bottom'; % options: top, left,bottom, right... indicates the position of the list of smaller plots
                nof_minor_rows = 1;
                if nargin > 2,
                    nof_minor_rows = varargin{1};
                    if nargin > 3,
                        mode = varargin{2};
                    end
                end
                this.viewer.nof_minor_rows = nof_minor_rows;
                
                nof_major_rows = 5;
                nr = nof_minor_rows + nof_major_rows;
                nc = ceil(nof_figures/nof_minor_rows);
                switch mode
                    case 'bottom',
                        this.mergelist = {[1,nof_major_rows*nc]};
                        this.viewer.starting_index = nof_major_rows*nc + 1;
                        
                    case 'top',
                        this.mergelist = {[nof_minor_rows*nc+1,nr*nc]};
                        this.viewer.starting_index = 1;
                        
                    otherwise
                        this.mergelist = {[1,nof_major_rows*nc]};
                        this.viewer.starting_index = nof_major_rows*nc + 1;
                        
                end % switch: mode
                
            else
                
                this.mergelist = {};
                if nargin > 2,
                    this.mergelist = varargin{1};
                end
            end % ifelse: viewer mode or not??
            
            if nargin == 1,
                nc = round(ceil(2*sqrt(nr))/2);
                nr = round(floor(2*sqrt(nr))/2);
            end
            
            
            this.nof_rows = nr;
            this.nof_columns = nc;
            this.hfig = gcf;
            set(this.hfig,'Toolbar','figure','Units','normalized'); % set toolbar
            
            boxheight = 1/nr;
            boxwidth = 1/nc;
            
            this.hax = zeros(nr,nc);
            for ir = 1:nr, % all rows
              for ic = 1:nc, % al columns
                position = [((ic - 1)*boxwidth) ((nr - ir)*boxheight) boxwidth boxheight];
                this.hax(ir,ic) = axes('Units','normalized','OuterPosition',position,'Tag','hax','UserData',[ir,ic]);
                set(this.hax(ir,ic),'Units','pixels','LooseInset',this.loose_inset_px);
                set(this.hax(ir,ic),'Units','normalized');
                this.zoomed(ir,ic) = false;

                % Create subplot zoom buttons and prepare subplot zoom data
                this.subplotzoom_data(ir,ic).zm_btn = uicontrol(this.hfig,'style','push','tag','subplotzoom','UserData',[ir ic],'units','pixels',...
                    'string','+','fontsize',6,'Interruptible','off','callback',@(src, event)subplotzoom_cb(this,src,event,ir,ic));
                this.set_zoom_button_position(ir,ic); % set positions in axes
                this.subplotzoom_enabled(ir,ic) = 1; % 1 => with suplot zoom, 0 => without subplot zoom
                % init legend
                this.hlegend(ir,ic) = nan;
                this.legend_data{ir,ic} = this.legend_data_struct;

                this.subplotzoom_data(ir,ic).axpos_in = position;

                this.hcolorbar(ir,ic) = nan;
              end % for: all columns
            end % for: all rows
            
            
            
            %% merge sets in list
            %%------------------------------------------------------------------------
            if ~isempty(this.mergelist),
                if ~iscell(this.mergelist),
                    this.mergelist = {this.mergelist};
                end
                
                nof_combs = numel(this.mergelist);
                for icomb = 1:nof_combs,
                    sp2merge = this.mergelist{icomb};
                    
                    [ic,ir] = ind2sub([nc,nr],sp2merge);
                    leftpos = get(this.hax(min(ir),min(ic)),'OuterPosition');
                    rightpos = get(this.hax(max(ir),max(ic)),'OuterPosition');
                    
                    mergepos = [leftpos(1),...
                        rightpos(2),...
                        rightpos(1) + rightpos(3) - leftpos(1),...
                        leftpos(2) + leftpos(4) - rightpos(2)];
                    
                    
                    % remove redundant subplots including reduncant subplot
                    % zoom buttons and data
                    for rrem = (min(ir)):1:max(ir),
                        for crem = (min(ic)):1:max(ic),
                            if rrem > min(ir) || crem > min(ic),
                                delete(this.hax(rrem,crem)); % delete axis
                                delete(this.subplotzoom_data(rrem,crem).zm_btn) % delete subplotzoom button
                                this.subplotzoom_data(rrem,crem) = this.subplotzoom_data(min(ir),min(ic)); % delete subplotzoom_data
                                clear this.subplotzoom_data(rrem,crem);
                                this.hax(rrem,crem) = this.hax(min(ir),min(ic));
                            end
                        end
                    end
                    
                    for iir = 1:numel(ir),
                        this.subplotzoom_data(ir(iir),ic(iir)).axpos_in = mergepos;
                    end
                    set(this.hax(min(ir),min(ic)),'OuterPosition',mergepos,'ActivePositionProperty','OuterPosition');
                    set(this.hax(min(ir),min(ic)),'Units','pixels','LooseInset',this.loose_inset_px);
                    set(this.hax(min(ir),min(ic)),'Units','normalized');
                    
                    this.set_zoom_button_position(min(ir),min(ic));
                    this.subplotzoom_data(min(ir),min(ic)).axpos_in = get(this.hax(min(ir),min(ic)),'Position');  % Original axis position of hax [normalized]
                end % for: all combinations
            end
            
            this.store_axis_positions
            if this.subplotzoom_enabled == 0
              this.disable_subplotzoom;
            end
            
            
            
            %% Resizing function (if present)
            %%------------------------------------------------------------------------
            
            set(this.hfig,'ResizeFcn',@(src,evt)this.subplot_resize_fcn);
            set(this.hax(:),'DeleteFcn',@this.delete_axes);
            this.set_gca(1,1);
            
            
        end % fcn
        
        
        function x_sync_axes(this, list_linked_axes)
            %
            % X_SYNC_AXES Synchronises the x axis of a number of axes
            %             
            %
            % SYNTAX:
            %   <obj>.x_sync_axes(list_linked_axes);
            %
            % INPUT PARAMETER:
            %   list_linked_axes  Vector of axes numbers to be synchronised.
            %
            %
            
            
            
            h_ax_to_sync =[];
            for t=1:length(list_linked_axes)
                [ic,ir] = ind2sub([this.nof_columns,this.nof_rows],list_linked_axes(t));
                if (ir > 0) && (ir <= this.nof_rows) && (ic > 0) && (ic <= this.nof_columns)
                    h_ax_to_sync = [h_ax_to_sync this.hax(ir,ic)];
                else
                    disp('Invalid subplot index')
                end
            end
            linkaxes(h_ax_to_sync,'x')
            
            
            
            
            
            
        end %function time_sync_axes(list_linked_axes)
        
        
        function figtitle(this, titlestring,varargin)
            
            %
            % FIGTITLE adds a - multi-row - title for the entire figure. The
            %   extension of the title to multiple rows is done via the use of a
            %   cell array of strings. The text properties may be altered by the
            %   normal properties as VARARGIN parameters
            %
            % SYNTAX:
            %   <obj>.figtitle(titlestring,VARARGIN);
            %
            % INPUT PARAMETER:
            %   titlestring   A string or a cell array of strings containing the
            %                 text to use as the figure title.
            %
            % VARARGIN PARAMETERS:
            %   The varargin parameters can be used to set the text properties of
            %   the figure title. The VARARGIN parameters come in pairs:
            %   'property_name' and 'property_value'. An extensive list can thus
            %   be created.
            %
            
            set(0,'CurrentFigure',this.hfig);
            if ~iscell(titlestring),
                titlestring = {titlestring};
            end
            
            %% undo zooming (temporarily)
            [irzoomed,iczoomed] = find(this.zoomed == 1);
            if any(irzoomed),
                this.subplotzoom_cb([],[],irzoomed(1),iczoomed(1));
            end
            
            %% reset to legend-free axes
            this.resize_wo_legend;
            
            %% row and coltitle dimensions
            %--------------------------------------------------------------
            
            
            % find dimensions of existing titling
            coltitleheight = 0;
            rowtitlewidth = 0;
            subfigtitleheight = 0;
            if any(this.hax_coltitles),
                tmp = get(this.hax_coltitles(1),'Position');
                coltitleheight = tmp(:,4);
            end
            if ~isempty(this.hax_rowtitles),
                tmp = get(this.hax_rowtitles(1),'Position');
                rowtitlewidth = tmp(:,3);
            end
            
            % delete existing figure title
            delete(this.hax_figtitle);
            
            
            %% create figure title axes and text box
            %%----------------------------------------------------------------------
            % AXES
            this.hax_figtitle = axes('Units','normalized',...
                'Position',[0 0 1 1],...
                'Tag','figtitle',...
                'Visible','off',...
                'XTick',[],...
                'YTick',[],...
                'Box','off');
            
            % TEXTBOX
            htext_figtitle = text(0.5,0.5,'',...
                'Units','normalized',...
                'HorizontalAlignment','center',...
                'VerticalAlignment','middle',...
                'LineStyle','none',...
                'EdgeColor',[0 1 0],...
                'Tag','figtitle',...
                'FontWeight','bold',...
                'FontSize',12);
            
            % VARARGIN (text properties)
            if nargin > 2,
                for iarg = 2:2:nargin-1,
                    set(htext_figtitle,varargin{iarg-1},varargin{iarg});
                end
            end
            
            % text in textbox
            set(htext_figtitle,'String',titlestring);
            
            % correct AXES position
            poshtext_figtitle = get(htext_figtitle,'Extent');
            figtitleheight = max([poshtext_figtitle(4),1e-6]);
            
            newhax_figtitle_pos = [0 (1-figtitleheight) 1 figtitleheight];
            set(this.hax_figtitle,...
                'Position',newhax_figtitle_pos);
            
            
            %% adjust subfigtitle
            if ~isempty(this.hax_subfigtitle), % if subfigtitle exists
                subfigtitle_pos = get(this.hax_subfigtitle,'Position');
                subfigtitle_pos_new = [subfigtitle_pos(1),...
                    1 - subfigtitle_pos(4) - figtitleheight,...
                    subfigtitle_pos(3),...
                    subfigtitle_pos(4)];
                set(this.hax_subfigtitle,'Position',subfigtitle_pos_new);
                subfigtitleheight = subfigtitle_pos(4);
            end
            
            %% mod row and column titles
            %%------------------------------------------------------------------------
            if ~isempty(this.hax_coltitles),
                for ic = 1:this.nof_columns,
                    colposold = get(this.hax_coltitles(ic),'Position');
                    colposnew = [colposold(1),...
                        1 - figtitleheight - subfigtitleheight - colposold(4),...
                        colposold(3),...
                        colposold(4)];
                    set(this.hax_coltitles(ic),...
                        'Position',colposnew);
                end
            end
            
            % leftover for axes and row titles
            vleftover = 1 - figtitleheight - coltitleheight - subfigtitleheight;
            boxheight_new = vleftover/this.nof_rows;
            
            if ~isempty(this.hax_rowtitles),
                for ir = 1:this.nof_rows,
                    % get maximum width
                    rowposold = get(this.hax_rowtitles(ir),'Position');
                    rowtitlewidth = max(rowtitlewidth,rowposold(3));
                    rowposnew = [0,...
                        (ir - 1)*boxheight_new,...
                        rowtitlewidth,...
                        boxheight_new];
                    
                    set(this.hax_rowtitles(ir),...
                        'Position',rowposnew);
                end
            end
            
            
            %% mod axes positions
            %%------------------------------------------------------------------------
            haxu = unique(this.hax);
            
            % get positions
            if numel(haxu) > 1,
                allpositions = cell2mat(get(haxu,'OuterPosition'));
            else
                allpositions = get(haxu,'OuterPosition');
            end
            
            % minimum widths/heights
            minheight = min(allpositions(:,4));
            for iax = 1:numel(haxu),
                pos_old = get(haxu(iax),'OuterPosition');
                nof_row_boxes = round(pos_old(4)/minheight);
                rowstart = round((pos_old(2))/minheight);
                
                pos_new = [pos_old(1),...
                    rowstart*boxheight_new,...
                    pos_old(3),...
                    nof_row_boxes*boxheight_new];
                set(haxu(iax),'OuterPosition',pos_new);
                set(haxu(iax),'Units','pixels','LooseInset',this.loose_inset_px);
                set(haxu(iax),'Units','normalized');
                Imerged = find(this.hax == haxu(iax));
                for imerged = 1:numel(Imerged),
                    this.subplotzoom_data(Imerged(imerged)).axpos_in = pos_new;
                end
            end
            this.store_axis_positions
            
            % reset zoom buttons
            for ir = 1:this.nof_rows,
                for ic = 1:this.nof_columns,
                    this.place_legend(ir,ic);
                    this.set_zoom_button_position(ir,ic);
                end
            end
            
            % output parameter
            this.htitle = htext_figtitle;
            
            if any(irzoomed),
                this.set_gca(irzoomed(1),iczoomed(1));
                this.subplotzoom_cb([],[],irzoomed(1),iczoomed(1))
            else
                this.set_gca(1,1);
            end
            
        end % fcn
        
        
        function subfigtitle(this, titlestring, varargin)
            %
            % SUBFIGTITLE adds a - multi-row - SUBtitle for the entire figure. The
            %   extension of the title to multiple rows is done via the use of a
            %   cell array of strings. The text properties may be altered by the
            %   normal properties as VARARGIN parameters
            %
            % SYNTAX:
            %   <obj>.subfigtitle(titlestring,VARARGIN);
            %
            % INPUT PARAMETER:
            %   titlestring   A string or a cell array of strings containing the
            %                 text to use as the figure title.
            %
            % VARARGIN PARAMETERS:
            %   The varargin parameters can be used to set the text properties of
            %   the figure title. The VARARGIN parameters come in pairs:
            %   'property_name' and 'property_value'. An extensive list can thus
            %   be created.
            %
            
            set(0,'CurrentFigure',this.hfig);
            
            if ~iscell(titlestring),
                titlestring = {titlestring};
            end
            
            %% undo zooming (temporarily)
            [irzoomed,iczoomed] = find(this.zoomed == 1);
            if any(irzoomed),
                this.subplotzoom_cb([],[],irzoomed(1),iczoomed(1));
            end
            
            this.resize_wo_legend;
            
            %% row and coltitle dimensions
            %--------------------------------------------------------------
            
            coltitleheight = 0;
            rowtitlewidth = 0;
            figtitleheight = 0;
            if any(this.hax_coltitles),
                tmp = get(this.hax_coltitles(1),'Position');
                coltitleheight = tmp(:,4);
            end
            if ~isempty(this.hax_rowtitles),
                tmp = get(this.hax_rowtitles(1),'Position');
                rowtitlewidth = tmp(:,3);
            end
            if ~isempty(this.hax_figtitle),
                tmp = get(this.hax_figtitle,'Position');
                figtitleheight = tmp(4);
            end
            
            % delete existing figure title
            delete([this.hax_subfigtitle;allchild(this.hax_subfigtitle)]);
            
            %% create figure title axes and text box
            %%----------------------------------------------------------------------
            
            % AXES
            this.hax_subfigtitle = axes('Units','normalized',...
                'Position',[0 0 1 1],...
                'Tag','subfigtitle',...
                'Visible','off',...
                'XTick',[],...
                'YTick',[],...
                'Box','off');
            
            % TEXTBOX
            htext_subfigtitle = text(0.5,0.5,'',...
                'Units','normalized',...
                'HorizontalAlignment','center',...
                'VerticalAlignment','middle',...
                'LineStyle','none',...
                'EdgeColor',[0 1 0],...
                'Tag','subfigtitle',...
                'FontWeight','bold',...
                'FontSize',10);
            
            % VARARGIN
            if nargin > 2,
                for iarg = 2:2:nargin-1,
                    set(htext_subfigtitle,varargin{iarg-1},varargin{iarg});
                end
            end
            
            % text in textbox
            set(htext_subfigtitle,'String',titlestring);
            
            % correct AXES position
            poshtext_subfigtitle = get(htext_subfigtitle,'Extent');
            subfigtitleheight = max([poshtext_subfigtitle(4),1e-6]);
            
            newhax_subfigtitle_pos = [0,...
                (1 - subfigtitleheight - figtitleheight),...
                1,...
                subfigtitleheight];
            set(this.hax_subfigtitle,...
                'Position',newhax_subfigtitle_pos);
            
            
            %% mod row and column titles
            %%------------------------------------------------------------------------
            if ~isempty(this.hax_coltitles),
                for ic = 1:this.nof_columns,
                    colposold = get(this.hax_coltitles(ic),'Position');
                    colposnew = [colposold(1),...
                        1 - figtitleheight - subfigtitleheight - colposold(4),...
                        colposold(3),...
                        colposold(4)];
                    set(this.hax_coltitles(ic),...
                        'Position',colposnew);
                end
            end
            
            % leftover for axes and row titles
            vleftover = 1 - figtitleheight - coltitleheight - subfigtitleheight;
            boxheight_new = vleftover/this.nof_rows;
            
            if ~isempty(this.hax_rowtitles),
                for ir = 1:this.nof_rows,
                    % get maximum width
                    rowposold = get(this.hax_rowtitles(ir),'Position');
                    rowtitlewidth = max(rowtitlewidth,rowposold(3));
                    rowposnew = [0,...
                        (ir - 1)*boxheight_new,...
                        rowtitlewidth,...
                        boxheight_new];
                    
                    set(this.hax_rowtitles(ir),...
                        'Position',rowposnew);
                end
            end
            
            
            %% mod axes positions
            %%------------------------------------------------------------------------
            haxu = unique(this.hax);
            
            % get positions
            if numel(haxu) > 1,
                allpositions = cell2mat(get(haxu,'OuterPosition'));
            else
                allpositions = get(haxu,'OuterPosition');
            end
            
            % minimum widths/heights
            minheight = min(allpositions(:,4));
            for iax = 1:numel(haxu),
                pos_old = get(haxu(iax),'OuterPosition');
                nof_row_boxes = round(pos_old(4)/minheight);
                rowstart = round((pos_old(2))/minheight);
                
                pos_new = [pos_old(1),...
                    rowstart*boxheight_new,...
                    pos_old(3),...
                    nof_row_boxes*boxheight_new];
                set(haxu(iax),'OuterPosition',pos_new);
                set(haxu(iax),'Units','pixels','LooseInset',this.loose_inset_px);
                set(haxu(iax),'Units','normalized');
                Imerged = find(this.hax == haxu(iax));
                for imerged = 1:numel(Imerged),
                    this.subplotzoom_data(Imerged(imerged)).axpos_in = pos_new;
                end
            end
            this.store_axis_positions
            
            % reset zoom buttons
            for ir = 1:this.nof_rows,
                for ic = 1:this.nof_columns,
                    this.place_legend(ir,ic);
                    this.set_zoom_button_position(ir,ic);
                end
            end
            
            % output parameter
            this.hsubtitle = htext_subfigtitle;
            
            if any(irzoomed),
                this.set_gca(irzoomed(1),iczoomed(1));
                this.subplotzoom_cb([],[],irzoomed(1),iczoomed(1))
            else
                this.set_gca(1,1);
            end
        end % fcn
        
        
        function rowtitles(this,rowstring,varargin)
            
            %
            % ROWTITLES adds titles to all rows of axes. A set of titles equal to
            %   the number of rows must be given, otherwise the method will fail.
            %
            % SYNTAX:
            %   <obj>.rowtitles(titlestring,VARARGIN);
            %
            % INPUT PARAMETER:
            %   titlestring   A cell array of strings containing the row titles
            %                 for all subplot rows. The cell array length and the
            %                 number of subplot rows must be equal. If not, an
            %                 error will occur
            %
            % VARARGIN PARAMETERS:
            %   The varargin parameters can be used to set the text properties of
            %   the row titles. The VARARGIN parameters come in pairs:
            %   'property_name' and 'property_value'. An extensive list can thus
            %   be created.
            %
            
            set(0,'CurrentFigure',this.hfig);
            
            %% gather titles dimensions
            %%-------------------------------------------------------------------
            if ~iscell(rowstring),
                rowstring = {rowstring};
            end
            
            %% undo zooming (temporarily)
            [irzoomed,iczoomed] = find(this.zoomed == 1);
            if any(irzoomed),
                this.subplotzoom_cb([],[],irzoomed(1),iczoomed(1));
            end
            
            this.resize_wo_legend;
            delete(this.hax_rowtitles);
            
            % get figure title height
            rowtitlewidth_old = 0;
            if any(this.hax_rowtitles),
                tmp = get(this.hax_rowtitles(1),'Position');
                rowtitlewidth_old = tmp(3);
            end
            
            
            %% determine axes widths
            %%-----------------------------------------------------------
            
            rowtitlewidths = zeros(this.nof_rows,1);
            this.hax_rowtitles = zeros(this.nof_rows,1);
            htext_rtitle = zeros(this.nof_rows,1);
            for ir = 1:this.nof_rows,
                
                % AXES
                this.hax_rowtitles(this.nof_rows - ir + 1) = axes('Units','normalized',...
                    'Position',[0 0 1 1],...
                    'Tag','rowtitle',...
                    'UserData',ir,...
                    'Visible','off',...
                    'XTick',[],...
                    'YTick',[],...
                    'Units','normalized',...
                    'Box','off');
                
                % TEXTBOX
                htext_rtitle(this.nof_rows - ir + 1) = text(0.5,0.5,'',...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','middle',...
                    'EdgeColor',[1 0 0],...
                    'LineStyle','none',...
                    'Rotation',90,...
                    'Tag','rowtitle',...
                    'UserData',ir,...
                    'FontWeight','bold');
                
                % VARARGIN
                if nargin > 2,
                    for iarg = 2:2:nargin-1,
                        set(htext_rtitle(this.nof_rows - ir + 1),varargin{iarg-1},varargin{iarg});
                    end
                end
                set(htext_rtitle(this.nof_rows - ir + 1),'String',rowstring{ir});
                
                % text box has perfect width, modify axes with this width
                % correct column title dimensions
                posrtitle = get(htext_rtitle(this.nof_rows - ir + 1),'Extent');
                rowtitlewidths(this.nof_rows - ir + 1) = posrtitle(3);
                
            end % for: all row titles
            maxrowtitlewidth = max([max(rowtitlewidths),1e-6]);
            
            
            %% Determine space for 'normal' axes
            %%--------------------------------------------------------------------
            % determine subplot layout
            hleftover = 1 - maxrowtitlewidth; % subtract row title width
            
            % determine plot box dimensions
            boxwidth_new = hleftover/this.nof_columns;
            
            
            %% correct row titles
            %%-----------------------------------------------------------------------
            for ir = 1:this.nof_rows,
                % re-position and size the row title axes
                axposold = get(this.hax(this.nof_rows - ir + 1,1),'OuterPosition');
                ax_correct_position = [0,...
                    axposold(2),...
                    maxrowtitlewidth,...
                    axposold(4)];
                set(this.hax_rowtitles(ir),...
                    'Position',ax_correct_position);
            end
            
            
            %% subplots
            %%-------------------------------------------------------------
            haxu = unique(this.hax);
            if numel(haxu) > 1,
                allpositions = cell2mat(get(haxu,'OuterPosition'));
            else
                allpositions = get(haxu,'OuterPosition');
            end
            minwidth = min(allpositions(:,3));
            for iax = 1:numel(haxu),
                pos_old = get(haxu(iax),'OuterPosition');
                nof_col_boxes = round(pos_old(3)/minwidth);
                colstart = round((pos_old(1) - rowtitlewidth_old)/minwidth);
                
                pos_new = [maxrowtitlewidth + colstart*boxwidth_new,...
                    pos_old(2),...
                    nof_col_boxes*boxwidth_new,...
                    pos_old(4)];
                set(haxu(iax),'OuterPosition',pos_new);
            end
            
            
            %%  resize column titles again
            %%----------------------------------------------------------------
            if any(this.hax_coltitles),
                for icol = 1:numel(this.hax_coltitles),
                    % determine and set new column title axes dimensions
                    colposold = get(this.hax_coltitles(icol),'Position');
                    hax_coltitle_pos_new = [maxrowtitlewidth + (icol - 1)*boxwidth_new,...
                        colposold(2),...
                        boxwidth_new,...
                        colposold(4)];
                    set(this.hax_coltitles(icol),...
                        'Position',hax_coltitle_pos_new);
                end
            end
            this.store_axis_positions
            this.hrowtitles = htext_rtitle;
            
            % reset zoom buttons
            for ir = 1:this.nof_rows,
                for ic = 1:this.nof_columns,
                    this.set_zoom_button_position(ir,ic);
                    this.subplotzoom_data(ir,ic).axpos_in = get(this.hax(ir,ic),'OuterPosition');
                    this.place_legend(ir,ic);
                end
            end
            
            if any(irzoomed),
                this.set_gca(irzoomed(1),iczoomed(1));
                this.subplotzoom_cb([],[],irzoomed(1),iczoomed(1))
            end
            
        end % fcn
        
        
        function coltitles(this, colstring,varargin)
            
            %
            % COLTITLES adds titles to all columns of axes. A set of titles equal to
            %   the number of columns must be given, otherwise the method will fail.
            %
            % SYNTAX:
            %   <obj>.coltitles(titlestring,VARARGIN);
            %
            % INPUT PARAMETER:
            %   titlestring   A cell array of strings containing the column titles
            %                 for all subplot columns. The cell array length and the
            %                 number of subplot columns must be equal. If not, an
            %                 error will occur
            %
            % VARARGIN PARAMETERS:
            %   The varargin parameters can be used to set the text properties of
            %   the column titles. The VARARGIN parameters come in pairs:
            %   'property_name' and 'property_value'. An extensive list can thus
            %   be created.
            %
            
            set(0,'CurrentFigure',this.hfig);
            if ~iscell(colstring),
                colstring = {colstring};
            end
            
            delete(this.hax_coltitles);
            
            %% gather subplot data of this figure
            %%-------------------------------------------------------------------
            %% undo zooming (temporarily)
            [irzoomed,iczoomed] = find(this.zoomed == 1);
            if any(irzoomed),
                this.subplotzoom_cb([],[],irzoomed(1),iczoomed(1));
            end
            
            this.resize_wo_legend;
            
            % get figure title height
            figtitleheight = 0;
            subfigtitleheight = 0;
            rowtitlewidth = 0;
            if any(this.hax_figtitle),
                posfigtitle = get(this.hax_figtitle,'Position');
                figtitleheight = posfigtitle(4);
            end
            if any(this.hax_rowtitles),
                poscoltitles = get(this.hax_rowtitles(1),'Position');
                rowtitlewidth = poscoltitles(3);
            end
            if any(this.hax_subfigtitle),
                possubfigtitle = get(this.hax_subfigtitle,'Position');
                subfigtitleheight = possubfigtitle(4);
            end
            
            
            
            %% create axes and text boxes
            %%-----------------------------------------------------------
            coltitleheights = zeros(this.nof_rows,1);
            this.hax_coltitles = zeros(this.nof_columns,1);
            htext_ctitle = zeros(this.nof_rows,1);
            for ic = 1:this.nof_columns,
                % define initial axes
                this.hax_coltitles(ic) = axes('Units','normalized',...
                    'Position',[0 0 1 1],...
                    'Tag','coltitle',...
                    'UserData',ic,...
                    'Visible','off',...
                    'XTick',[],...
                    'YTick',[],...
                    'Units','normalized',...
                    'Box','off');
                
                % create wrongly located text box
                htext_ctitle(ic) = text(0.5,0.5,'',...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','middle',...
                    'LineStyle','none',...
                    'EdgeColor',[0 1 1],...
                    'Tag','coltitle',...
                    'UserData',ic,...
                    'FontWeight','bold');
                % set varargin parameters
                if nargin > 2,
                    for iarg = 2:2:nargin-1,
                        set(htext_ctitle(ic),varargin{iarg-1},varargin{iarg});
                    end
                end
                set(htext_ctitle(ic),'String',colstring{ic});
                
                % text box has perfect width, modify axes with this width
                % correct column title dimensions
                posctitle = get(htext_ctitle(ic),'Extent');
                coltitleheights(ic) = posctitle(4);
                
            end % for: all col titles
            maxcoltitleheight = max([max(coltitleheights(:)),1e-6]);
            
            
            %% Determine space for 'normal' axes
            %%--------------------------------------------------------------------
            
            % determine subplot layout
            vleftover = 1 - figtitleheight - maxcoltitleheight - subfigtitleheight; % no changes in vertical direction
            
            % determine plot box dimensions
            boxheight_new = vleftover/this.nof_rows;
            
            
            %% move and resize row title axes
            %%-----------------------------------------------------------------------
            minwidth = inf;
            for iax = 1:numel(this.hax(:)),
                tmp = get(this.hax(iax),'OuterPosition');
                minwidth = min(minwidth,tmp(3));
            end
            
            for ic = 1:this.nof_columns,
                % re-position and size the axes
                ax_correct_position = [rowtitlewidth + (ic-1)*minwidth,...
                    1 - figtitleheight - maxcoltitleheight - subfigtitleheight,...
                    minwidth,...
                    maxcoltitleheight];
                set(this.hax_coltitles(ic),...
                    'Position',ax_correct_position);
            end
            
            %% modify axes
            %%------------------------------------------------------------------------
            haxu = unique(this.hax);
            if numel(haxu) > 1,
                allpositions = cell2mat(get(haxu,'OuterPosition'));
            else
                allpositions = get(haxu,'OuterPosition');
            end
            
            minheight = min(allpositions(:,4));
            for iax = 1:numel(haxu),
                pos_old = get(haxu(iax),'OuterPosition');
                nof_row_boxes = round(pos_old(4)/minheight);
                rowstart = round((pos_old(2))/minheight);
                
                pos_new = [pos_old(1),...
                    rowstart*boxheight_new,...
                    pos_old(3),...
                    nof_row_boxes*boxheight_new];
                set(haxu(iax),'OuterPosition',pos_new);
                set(haxu(iax),'Units','pixels','LooseInset',this.loose_inset_px);
                set(haxu(iax),'Units','normalized');
            end
            
            %% Mod row titles
            %%-----------------------------------------------------------------------
            
            for ir = 1:this.nof_rows,
                if any(this.hax_rowtitles),
                    rowtitleposnew = [0,...
                        (ir - 1)*boxheight_new,...
                        rowtitlewidth,...
                        boxheight_new];
                    set(this.hax_rowtitles(ir),'Position',rowtitleposnew);
                end
            end
            
            this.store_axis_positions
            
            % reset zoom buttons
            for ir = 1:this.nof_rows,
                for ic = 1:this.nof_columns,
                    this.set_zoom_button_position(ir,ic);
                    this.subplotzoom_data(ir,ic).axpos_in = get(this.hax(ir,ic),'OuterPosition');
                    this.place_legend(ir,ic);
                end
            end
            
            if any(irzoomed),
                this.set_gca(irzoomed(1),iczoomed(1));
                this.subplotzoom_cb([],[],irzoomed(1),iczoomed(1))
            end
            this.hcoltitles = htext_ctitle;
            
        end % fcn
        
        
        function enable_subplotzoom(this,varargin)
            
            %
            % ENABLE_SUBPLOTZOOM sets the subplotzoom button in the top-right
            %   corner of the axes. The method is controlled via VARARGIN
            %   parameters, with which a - set of - axes indices, or a set of
            %   axes row and column positions may be presented.
            %
            %   Omitting a VARARGIN parameter will cause the script to enable
            %   SUBPLOTZOOM for all axes.
            %
            % SYNTAX:
            %   <obj>.enable_subplotzoom(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   <no input parameters> : SUBPLOTZOOM will be enabled for all axes
            %   1 input parameter :   A vector containing the axes indices for
            %                         which SUBPLOTZOOM must be enabled.
            %   2 input parameters :  Two vectors containing the row and column
            %                         indices of the axes for which SUBPLOTZOOM
            %                         must be enabled
            %
            
            if nargin == 1,
                Iax = 1:this.nof_rows*this.nof_columns;
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
            elseif nargin == 2,
                Iax = varargin{1};
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
            elseif nargin == 3,
                Ir = varargin{1};
                Ic = varargin{2};
            end
            
            for iter = 1:numel(Ir),
                ir = Ir(iter);
                ic = Ic(iter);
                if ishandle(this.hax(ir,ic)),
                  if ~isempty(this.subplotzoom_data(ir,ic))
                      % *** corner ***
                      set(this.subplotzoom_data(ir,ic).zm_btn,'Visible','on');     % Set axis units
                      this.subplotzoom_enabled(ir,ic) = 1;
                  end
                end
            end % for: all sets
        end % fcn
        
        
        function disable_subplotzoom(this,varargin)
            
            %
            % DISABLE_SUBPLOTZOOM disables the subplotzoom button in the top-right
            %   corner of the axes. The method is controlled via VARARGIN
            %   parameters, with which a - set of - axes indices, or a set of
            %   axes row and column positions may be presented.
            %
            %   Omitting a VARARGIN parameter will cause the script to disable
            %   SUBPLOTZOOM for all axes.
            %
            % SYNTAX:
            %   <obj>.disable_subplotzoom(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   <no input parameters> : SUBPLOTZOOM will be disabled for all axes
            %   1 input parameter :   A vector containing the axes indices for
            %                         which SUBPLOTZOOM must be disabled.
            %   2 input parameters :  Two vectors containing the row and column
            %                         indices of the axes for which SUBPLOTZOOM
            %                         must be disabled
            %
            
            if nargin == 1,
                Iax = 1:this.nof_rows*this.nof_columns;
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
            elseif nargin == 2,
                Iax = varargin{1};
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
            elseif nargin == 3,
                Ir = varargin{1};
                Ic = varargin{2};
            end
            
            for iter = 1:numel(Ir),
                ir = Ir(iter);
                ic = Ic(iter);
                % *** corner ***
                if ishandle(this.hax(ir,ic)),
                  set(this.subplotzoom_data(ir,ic).zm_btn,'Visible','off');     % Set axis units
                  %         Imat = find();
                  this.subplotzoom_enabled(this.hax == this.hax(ir,ic)) = 0;
                end
            end % for: all inputs
        end % fcn
        
        
        function set_gca(this,varargin)
            
            %
            % SET_GCA sets the current axes of the figure. The behaviour is
            %   controlled by VARARGIN inputs.
            %
            % SYNTAX:
            %   <obj>.set_gca(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   1 input parameter :   The index of the axes to be made the
            %                         current one
            %   2 input parameters :  The row and column indices for the axes to
            %                         be made the current one
            %
            %                         or
            %
            %                         parameter 1 : 'viewer', parameter 2 : axes
            %                         index
            %
            
            
            if nargin == 1,
                ir = this.current_axes(1);
                ic = this.current_axes(2);
            else
                if strcmp(varargin{1},'viewer'),
                    [ic,ir] = ind2sub([this.nof_columns,this.nof_rows],this.viewer.starting_index + varargin{2} - 1);
                else
                    if nargin == 2,
                        [ic,ir] = ind2sub([this.nof_columns,this.nof_rows],varargin{1});
                    elseif nargin == 3,
                        ir = varargin{1};
                        ic = varargin{2};
                    end
                end
            end
            
            if (ir > 0) && (ir <= this.nof_rows) && (ic > 0) && (ic <= this.nof_columns),
                set(0,'CurrentFigure',this.hfig);
                set(this.hfig,'CurrentAxes',this.hax(ir,ic));
            else
                disp('Invalid subplot index')
            end
            
            this.current_axes = [ir,ic];
        end % fcn: set_gca
        
        
        function extract_axes(this,varargin)
            
            %
            % EXTRACT_AXES extracts the wanted axes or set of axes from the
            %   subplot_grid object created.
            %
            % SYNTAX:
            %   <obj>.extract_axes(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   1 input parameter :   A vector of axes indices to be extracted
            %                         from the subplot_grid object
            %   2 input parameters :  The vectors for the row and column axes
            %                         positions to be extracted.
            %
            
            if nargin == 2,
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],varargin{1});
            elseif nargin == 3,
                Ir = varargin{1};
                Ic = varargin{2};
            end
            
            for iter = 1:numel(Ir),
                ir = Ir(iter);
                ic = Ic(iter);
                % get wanted axes handle
                haxc = this.hax(ir,ic);
                
                % create new figure, and copy axes content
                figure;
                set(gcf,'WindowKeyPressFcn',get(this.hfig,'WindowKeyPressFcn'));
                
                % is interaxes enabled
                interaxes_index = false;
                if isfield(this,'interaxes_data'),
                    interaxes_index = find(cat(1,this.interaxes_data.axes_handle) == haxc);
                end
                if interaxes_index,
                    % set interaxes data for extracted figure
                    
                    % reset current selection
                    if ~isnan(this.interaxes_data(interaxes_index).selected_object_handle), % if: selection active -> disable
                        modfields = fieldnames(this.interaxes_data(interaxes_index).local_selection_mods);
                        
                        for ifield = 1:numel(modfields),
                            if isprop(this.interaxes_data(interaxes_index).selected_object_handle,modfields{ifield}),
                                saveprops.(modfields{ifield}) = get(this.interaxes_data(interaxes_index).selected_object_handle,modfields{ifield});
                            end
                        end
                        set(this.interaxes_data(interaxes_index).selected_object_handle,this.interaxes_data(interaxes_index).selected_object_props);
                        haxnew = copyobj(haxc,gcf);
                        
                        % set selection properties back
                        set(this.interaxes_data(interaxes_index).selected_object_handle,saveprops);
                    else
                        haxnew = copyobj(haxc,gcf);
                    end % if: selection active
                    this.interaxes_data(end+1).axes_handle = haxnew;
                    this.interaxes_data(end).selected_object_handle = nan;
                    this.interaxes_data(end).selected_object_props = [];
                    this.interaxes_data(end).local_selection_mods = this.interaxes_data(interaxes_index).local_selection_mods;
                    ttl = get(get(haxnew,'Title'),'String');
                    ttl(end) = [];
                    set(get(haxnew,'Title'),'String',ttl);
                    
                    delete(findobj(haxnew,'Tag','selbox'));
                else
                    haxnew = copyobj(haxc,gcf);
                end
                
                % maximize outerposition
                props.Units = 'normalized';
                props.OuterPosition = [0 0 1 1];
                
                set(haxnew,props);
            end % for: all to-extract axes
            
        end % fcn
        
        
        function hide_axes(this,varargin)
            
            %
            % HIDE_AXES hides a set of axes from the figure. Can be used to blank
            %   'empty' axes or create space for annotational texts.
            %
            % SYNTAX:
            %   <obj>.hide_axes(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   <no input parameters> : all axes will be hidden.
            %   1 input parameter : A vector containing the axes indices to
            %                       hide
            %   2 input parameters : Two vectors containing the row and column
            %                        indices of the axes to hide
            %
            
            if nargin == 1,
                Iax = 1:(this.nof_rows*this.nof_columns);
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
            elseif nargin == 2,
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],varargin{1});
            elseif nargin == 3,
                Ir = varargin{1};
                Ic = varargin{2};
            end
            
            for iter = 1:numel(Ir),
                ir = Ir(iter);
                ic = Ic(iter);
                kids = allchild(this.hax(ir,ic));
                set([this.hax(ir,ic);kids(isprop(kids,'Visible'))],'Visible','off');
                set(this.subplotzoom_data(ir,ic).zm_btn,'Visible','off');
                this.hidden_axes(end+1) = this.hax(ir,ic);
            end
            
        end
        
        
        function hide_empty_axes(this)
            
            %
            % HIDE_EMPTY_AXES hides all axes without graphical content in the
            %   figure.
            %
            % SYNTAX:
            %   <obj>.hide_empty_axes;
            %
            %
            
            for ir = 1:this.nof_rows,
                for ic = 1:this.nof_columns,
                    if numel(findobj(this.hax(ir,ic),'-not','Type','text')) == 1,
                        this.hide_axes(ir,ic);
                    end % if: only axes itself is found
                end
            end % for: all axes
            
        end
        
        
        function show_axes(this,varargin)
            
            %
            % SHOW_AXES can be used to make axes which have been hidden by
            %   re-appear. By default, at startup, all axes are shown.
            %
            % SYNTAX:
            %   <obj>.show_axes(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   <no input parameters> : all axes will be shown.
            %   1 input parameter : A vector containing the axes indices to
            %                       show
            %   2 input parameters : Two vectors containing the row and column
            %                        indices of the axes to show
            %
            
            if nargin == 1,
                Iax = 1:(this.nof_rows*this.nof_columns);
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
            elseif nargin == 2,
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],varargin{1});
            elseif nargin == 3,
                Ir = varargin{1};
                Ic = varargin{2};
            end
            
            for iter = 1:numel(Ir),
                ir = Ir(iter);
                ic = Ic(iter);
                kids = allchild(this.hax(ir,ic));
                set([this.hax(ir,ic);kids(isprop(kids,'Visible'))],'Visible','on');
                set(this.subplotzoom_data(ir,ic).zm_btn,'Visible','on');
                irow = find(this.hidden_axes == this.hax(ir,ic));
                if any(irow),
                    this.hidden_axes(irow) = [];
                end
            end
            
            
        end
        
        
        function enable_interaxes(this,varargin)
            
            %
            % ENABLE_INTERAXES enables the INTERAXES functionality for a set of
            %   axes.
            %
            %   With the INTERAXES function enabled, the user may click on the
            %   graph and the data points closest to the clicked-on point are
            %   selected. This implies a highlighting of the line (in case of
            %   line graphs) and the display of the data point location in the
            %   title.
            %
            %   In addition, after selection, the use of the arrow keys will move
            %   the selection box in that direction.
            %
            %   NOTE: it has been checked to work correctly for graphical
            %   objects: LINE, IMAGE and SURFACE.
            %
            % SYNTAX:
            %   <obj>.enable_interaxes(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   <no input parameters> : INTERAXES will be enabled for all axes
            %   1 input parameter : A vector containing the axes indices to
            %                       enable INTERAXES for
            %   2 input parameters : Two vectors containing the row and column
            %                        indices of the axes to enable INTERAXES for
            %
            
            Iax = 1:(this.nof_rows*this.nof_columns);
            [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
            if nargin > 1,
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],varargin{1});
                if nargin > 2,
                    Ir = varargin{1};
                    Ic = varargin{2};
                end
            end
            
            for iter = 1:numel(Ir),
                ir = Ir(iter);
                ic = Ic(iter);
                
                if ishandle(this.hax(ir,ic)),
                  haxc = this.hax(ir,ic);
                  % check for valid plot types
                  plottypes = unique(get(allchild(this.hax(ir,ic)),'Type'));
                  if ~isempty(plottypes),
                      if ~sum(ismember(plottypes,this.interaxes_supported_types)),
%                           warning(sprintf('Axes (%d,%d) does not contain valid plot types. INTERAXES function not enabled',ir,ic));
                          continue;
                      end
                  end

                  if ~isempty(this.interaxes_data),
                      if ismember(haxc,cat(1,this.interaxes_data(:).axes_handle)),
                          %             warning('INTERAXES function already enable for axes (%d,%d)',ir,ic);
                          continue;
                      end
                  end

                  set(haxc,'ButtonDownFcn',@(src,evt)this.interaxes(src,evt,ir,ic));
                  set(allchild(haxc),'ButtonDownFcn',@(src,evt)this.interaxes(src,evt,ir,ic));
                  set(this.hfig,'WindowKeyPressFcn',@(src,evt)this.interaxes(src,evt,ir,ic));
                  ttl = get(get(haxc,'Title'),'String');
                  if ~iscell(ttl),
                      ttl = {ttl};
                      set(get(haxc,'Title'),'String',ttl)
                  end

                  % set interaxes_state
                  this.interaxes_data(end+1).axes_handle = this.hax(ir,ic);
                  this.interaxes_data(end).selected_object_handle = nan;
                  this.interaxes_data(end).selected_object_props = [];
                  this.interaxes_data(end).local_selection_mods = this.interaxes_selection_mods;
                end
                
            end % for: all inputs
            
        end % fcn
        
        
        function disable_interaxes(this,varargin)
            
            %
            % DISABLE_INTERAXES disables the INTERAXES functionality for a set of
            %   axes.
            %
            %   With the INTERAXES function enabled, the user may click on the
            %   graph and the data points closest to the clicked-on point are
            %   selected. This implies a highlighting of the line (in case of
            %   line graphs) and the display of the data point location in the
            %   title.
            %
            %   In addition, after selection, the use of the arrow keys will move
            %   the selection box in that direction.
            %
            %   NOTE: it has been checked to work correctly for graphical
            %   objects: LINE, IMAGE and SURFACE.
            %
            % SYNTAX:
            %   <obj>.disable_interaxes(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   <no input parameters> : INTERAXES will be disabled for all axes
            %   1 input parameter : A vector containing the axes indices to
            %                       disable INTERAXES for
            %   2 input parameters : Two vectors containing the row and column
            %                        indices of the axes to disable INTERAXES for
            %
            
            if nargin > 0, % no inputs
                Iax = 1:this.nof_rows*this.nof_columns;
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
                if nargin > 1, % indices
                    Iax = varargin{1};
                    [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
                    if nargin > 2,
                        Ir = varargin{1};
                        Ic = varargin{2};
                    end
                end
            end
            
            
            if numel(this.interaxes_data), % if: anything has INTERAXES enabled
                h_interaxes = cat(1,this.interaxes_data(:).axes_handle); % all interaxes handles
                
                for iter = 1:numel(Ir),
                    ir = Ir(iter);
                    ic = Ic(iter);
                    if ishandle(this.hax(ir,ic)),
                      if ismember(this.hax(ir,ic),h_interaxes),
                        index = find(h_interaxes == this.hax(ir,ic));
                        fnames = fieldnames(this.interaxes_data(index).local_selection_mods);
                        set(this.hax(ir,ic),'ButtonDownFcn',[]);
                        kids = allchild(this.hax(ir,ic));
                        bdkids = isprop(kids,'ButtonDownFcn');
                        set(kids(bdkids),'ButtonDownFcn',[]);
                        % remove selection box
                        hselbox = findobj(this.hax(ir,ic),'Tag','selbox');
                        delete(hselbox);
                        % correct title
                        ttl = get(get(this.hax(ir,ic),'Title'),'String');
                        if iscell(ttl) && numel(ttl{end}) >= 11,
                            if strcmp(ttl{end}(1:11),'Datapoint :'),
                                ttl(end) = [];
                                set(get(gca,'Title'),'String',ttl);
                                set(get(this.hax(ir,ic),'Title'),'String',ttl);
                            end % if: wording 'Datapoint :' exists
                        end % if: enough title chars exist
                        
                        
                        % reset zoom buttons
                        this.set_zoom_button_position(ir,ic);
                        
                        % reset selection modifications
                        for ifield = 1:numel(fnames),
                            if isprop(this.interaxes_data(index).selected_object_handle,fnames{ifield}),
                                set(this.interaxes_data(index).selected_object_handle,fnames{ifield},this.interaxes_data(index).selected_object_props.(fnames{ifield}));
                            end
                        end
                        % save 'interaxes_state'
                        this.interaxes_data(index) = [];
                    else
                        warning(2,'INTERAXES was - already - disabled for subplot (%d,%d)',ir,ic);
                    end % for: all to-check axes
                    end
                end % for: all axes
                
            else
                warning(3,'INTERAXES has not been set yet. So cannot be disabled!');
            end % ifelse: interaxes enabled??
            
        end % fcn: disable interaxes
        
        
        function overwrite_interaxes_selection_mods(this,varargin)
            
            %
            % OVERWRITE_INTERAXES_SELECTION_MODS sets/overwrites the properties
            %   of the selected objects. Any object property may be set. If the
            %   set is left empty, than no difference between a selected and a
            %   not-selected object is seen.
            %
            %   By default, the selection mods are 'LineWidth' == 2, and
            %   'LineStyle' = '-'.
            %
            %   The selection mods are modifyable per axes.
            %
            % SYNTAX:
            %   <obj>.overwrite_interaxes_selection_mods(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   2 input parameters :
            %       1.  The index of the axes for which the selection mods must be
            %           changed
            %       2.  A cell array of plot properties to be set as the
            %           selection mods for the specific axes
            %   3 input parameters:
            %       1.  The row index of the axes for which the selections mods
            %           must be changed
            %       2.  It's corresponding column index.
            %       3.  A cell array of plot properties to be set as the
            %           selection mods for the specific axes
            %
            
            if nargin == 3,
                [ic,ir] = ind2sub([this.nof_columns,this.nof_rows],varargin{1});
                input = varargin{2};
            elseif nargin == 4,
                ir = varargin{1};
                ic = varargin{2};
                input = varargin{4};
            end
            haxc = this.hax(ir,ic);
            iinteraxes = find(cat(1,this.interaxes_data(:).axes_handle) == haxc);
            
            if any(iinteraxes),
                this.interaxes_data(iinteraxes).local_selection_mods = input;
            end
            
        end % fcn
        
        
        function legend(this,elmspecs,textlines,varargin)
            
            %
            % LEGEND creates a non-dependend legend to a specific subplot.
            %
            %   It works by supplying a set of element specifications (e.g.,
            %   'r+--', to plot red a dotted line with +'s for markers) and a set
            %   (of equal size) of text lines.
            %
            %   Omission of text lines results in the taking of empty strings for
            %   the elements.
            %
            %   The default location of the legend is the 'northeast' position
            %   inside the axes.
            %
            %   It is possible to add plot properties for every element by
            %   breaking down the cell structure in two more parts. A valid call
            %   to this method is for example:
            %
            %     this.legend({{'ko:','Color',0.7*[1 1 1]},'r+},{'string
            %     1';'string2'});
            %
            %   In the above example, the first legend element has it's color
            %   changed to light grey. The list may be extended at will.
            %
            % SYNTAX:
            %   <obj>.legend(element_specs,textlines,VARARGIN);
            %
            % INPUT PARAMETERS:
            %   element_specs   [cell] An array of plot specifications in the
            %                          formats allowed for functions as 'plots.
            %                          For example 'r+--' is a valid entry.
            %
            %                          A comma-separated list of plot properties
            %                          may be added to modify the plotted line.
            %   textlines       [cell] An array of text lines belonging to the
            %                          element specs
            %
            % VARARGIN PARAMETERS:
            %   1. (location)  [char] A string specifying the location of the
            %                         legend. Options are:
            %                           'north'
            %                           'northeast' (default)
            %                           'east'
            %                           'southeast'
            %                           'south'
            %                           'southwest'
            %                           'west'
            %                           'northwest'
            %                         The post-fix 'outside' may be added. This
            %                         will result in the placement of the legend
            %                         outside the axes. The axes will be resized
            %                         to accomodate this.
            %   2. (print_legend_title) [bool] Indicates whether the legend
            %                                  should have the title 'legend' in
            %                                  bold face on the top row
            %
            
            ax_parent = gca;
            % find axes
            [Ir,Ic] = find(this.hax == ax_parent);
            
            orientation = [];
            print_legend_title = 1;
            location = 'northeast';
            if nargin > 3,
                location = varargin{1}; % default: NorthEast
                if nargin > 4,
                    print_legend_title = varargin{2};
                    if nargin > 5,
                        orientation = varargin{3};
                    end
                end
            end
            
            
            if ~iscell(textlines),
                textlines = {textlines};
            end
            
            if numel(elmspecs) > numel(textlines),
                xprintf('warning','Number of elements (%d) exceeds number of text lines (%d). Empty lines added!\n',numel(elmspecs),numel(textlines));
                textlines((1+numel(textlines)):numel(elmspecs)) = cell(1,(numel(elmspecs) - numel(textlines)));
            end
            
            nof_elements = numel(elmspecs);
            
            ir = Ir(1);
            ic = Ic(1);
            
            this.legend_data{ir,ic}.location = location;
            this.legend_data{ir,ic}.print_legend_title = print_legend_title;
            this.legend_data{ir,ic}.orientation = orientation;
            this.hlegend(ir,ic) = axes('position',[0 0 1 1]);
            set(this.hlegend(ir,ic),...
                'Box','on',...
                'Tag','legend',...
                'YLim',[-nof_elements-1-this.legend_data{ir,ic}.print_legend_title 0],...
                'Units','pixels',...
                'NextPlot','add');
            
            % set x axis to pixel sizes
            legpos = get(this.hlegend(ir,ic),'Position');
            set(this.hlegend(ir,ic),'XLim',[0 legpos(3)-1]);
            
            totalheight = 0;
            legend_text_width = 0;
            if this.legend_data{ir,ic}.print_legend_title,
                hlegtitle = text(0,0,' Legend:',...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','top',...
                    'FontWeight','bold',...
                    'FontSize',8);
                
                set(hlegtitle,'Units','pixels');
                exttop = get(hlegtitle,'Extent');
                textheight = exttop(4);
                totalheight = textheight;
                legend_text_width = exttop(3);
                set(hlegtitle,'Units','data');
            end % i: add 'legend' as title
            
            set(gcf,'CurrentAxes',this.hlegend(ir,ic));
            for iel = 1:nof_elements,
                yval = -(iel + this.legend_data{ir,ic}.print_legend_title);
                
                nof_props = 0;
                if iscell(elmspecs{iel}),
                    elmspec_start = elmspecs{iel}{1};
                    nof_props = floor((numel(elmspecs{iel}) - 1)/2);
                else
                    elmspec_start = elmspecs{iel};
                end
                hplot = plot(linspace(10,50,3),yval+[0 0 0],elmspec_start);hold on;
                for iprop = 1:nof_props,
                    locname = (iprop - 1)*2 + 1;
                    locval = iprop*2; %#ok<NASGU>
                    eval(['set(hplot,''',elmspecs{iel}{1+locname},''',elmspecs{iel}{1+locval})'])
                end
                hcopy = copyobj(hplot,gca); % copy marker
                set(hcopy,'XData',30,'YData',yval); % create a single marker
                set(hplot,'Marker','none'); % remove 3 old markers
                clear htmp
                htmp = text(65,yval,textlines{iel},...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','middle',...
                    'FontSize',8);
                
                set(htmp,'Units','pixels');
                ext = get(htmp,'Extent');
                
                set(htmp,'Units','data');
                totalheight = totalheight + ext(4);
                legend_text_width = max(legend_text_width,(ext(3) + ext(1)));
                
                
            end % for: all elements
            
            legpos(3) = legend_text_width;
            legpos(4) = totalheight;
            set(this.hlegend(ir,ic),'Position',legpos,...
                'XLim',[0 legend_text_width-1],...
                'Box','on',...
                'XTick',[],...
                'YTick',[]);
            
            this.place_legend(ir,ic);
            
            % set data for all combined sets
            ir1 = ir;
            ic1 = ic;
            nof_comb = numel(Ir);
            for icomb = 1:nof_comb,
                ir = Ir(icomb);
                ic = Ic(icomb);
                this.hlegend(ir,ic) = this.hlegend(ir1,ic1);
                this.legend_data{ir,ic} = this.legend_data{ir1,ic1};
                this.set_zoom_button_position(ir,ic);

            end % for: all merged shit
            
            this.set_gca;
            
        end
        
        
        function remove_legend(this,varargin)
            
            %
            % REMOVE_LEGEND Remove the legend of one or more subplots.
            %
            % SYNTAX:
            %   <obj>.remove_legend(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   <no input parameters> : The legends of all subplots will be
            %                           removed
            %   1 input parameter : A vector containing the axes indices to
            %                       remove legends for
            %   2 input parameters : Two vectors containing the row and column
            %                        indices of the axes to remove the legends for
            %
            
            if nargin > 0, % no inputs
              Iax = 1:this.nof_rows*this.nof_columns;
              [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
              if nargin > 1, % indices
                Iax = varargin{1};
                [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
                if nargin > 2,
                  Ir = varargin{1};
                  Ic = varargin{2};
                end
              end
            end
            
            for iter = 1:numel(Ir),
              ir = Ir(iter);
              ic = Ic(iter);
              if ishandle(this.hlegend(ir,ic)),
                delete(this.hlegend(ir,ic));
                this.hlegend(ir,ic) = nan;
                units = get(this.hax(ir,ic),'Units');
                set(this.hax(ir,ic),'Units','normalized','OuterPosition',this.subplotzoom_data(ir,ic).axpos_in);
                set(this.hax(ir,ic),'Units','pixels','LooseInset',this.loose_inset_px);
                % reset zoombutton
                uistack(this.hax(ir,ic),'bottom');
                set(this.hax(ir,ic),'Units',units);
                this.set_zoom_button_position(ir,ic);
              end % if: axes has legend
            end % for: all axes
        end % fcn: remove legend
        
        
        function relocate_legend(this,location,varargin)
            
            %
            % RELOCATE_LEGEND relocates the legend of one or more subplots
            %
            % SYNTAX:
            %   <obj>.legend(VARARGIN);
            %
            %
            % INPUT PARAMETERS:
            %   location  [char] String specifying the location of the legend(s).
            %                    Options are:
            %                       'north'
            %                       'northeast' (default)
            %                       'east'
            %                       'southeast'
            %                       'south'
            %                       'southwest'
            %                       'west'
            %                       'northwest'
            %                    The post-fix 'outside' may be added. This
            %                    will result in the placement of the legend
            %                    outside the axes. The axes will be resized
            %                    to accomodate this.
            %
            % VARARGIN PARAMETERS:
            % VARARGIN PARAMETERS:
            %   <no input parameters> : The legends of all subplots will be
            %                           removed
            %   1 input parameter : A vector containing the axes indices to
            %                       relocate the legends for
            %   2 input parameters : Two vectors containing the row and column
            %                        indices of the axes to relocate the legends
            %                        for.
            %
            
            pause(0.2);
            if nargin == 2,
                Ir = this.current_axes(1);
                Ic = this.current_axes(2);
            else
                if nargin > 2, % indices
                    Iax = varargin{1};
                    [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
                    if nargin > 3,
                        Ir = varargin{1};
                        Ic = varargin{2};
                    end % if: all input parameters
                end % if: 3 input parameters
            end % if only location given
            
            for iax = 1:numel(Ir),
                ir = Ir(iax);
                ic = Ic(iax);
                Imerged = find(this.hax(:) == this.hax(ir,ic));
                for iaxm = 1:numel(Imerged),
                    this.legend_data{Imerged(iaxm)}.location = location;
                end
                this.place_legend(ir,ic,location);
            end
            
            
            
        end % fcn: relocate_legend
        
        
        function varargout = colorbar(this,varargin)
          
            %
            % COLORBAR adds a standard MATLAB colorbar to a figure
            %
            %   See for more help on the COLORBAR method the help of the
            %   corresponding MATLAB function.
            %
            % SYNTAX:
            %   VARARGOUT = <obj>.colorbar(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   The input parameters are equal to the input parameters in
            %   the normal MATLAB colorbar function except for the 'off',
            %   'hide' and 'delete' strings.
            %
            
          pause(0.5);
          hax1 = gca;
          location = 'EastOutside';
          if nargin > 1,
            if strcmp(varargin{1},'peer'),
              hax1 = varargin{2};
              if nargin > 3,
                location = varargin{3};
              end
            else
              location = varargin{1};
            end
          end
          
          [ir,ic] = ind2sub(size(this.hax),find(this.hax == hax1,1,'first'));
          if ishandle(this.hcolorbar(ir,ic)),
            delete(this.hcolorbar(ir,ic));
          end
          
          hcb = colorbar('peer',this.hax(ir,ic),location);
          this.hcolorbar(ir,ic) = hcb;
          
          this.set_zoom_button_position(ir,ic);
          
          if nargout > 0,
            varargout{1} = hcb;
          end
          
        end % fcn: colorbar
        
        
        function set_padding(this,varargin)

            %
            % SET_PADDING (re)sets the whitespace padding between axes.
            %
            %   The input is in pixels and should be a 1x4 vector for all 4
            %   sides of the axes.
            %
            % SYNTAX:
            %   <obj>.set_padding(VARARGIN);
            %
            % VARARGIN PARAMETERS:
            %   <no input>    : The padding is reset to the default value
            %                   of 5 pixels around.
            %   parameter 1   : 1x4 vector containing the padding in pixels
            %                   for all 4 sides. The format is [left,bottom,right,top] 
            %
          
          this.loose_inset_px = this.loose_inset_px_default;
          if nargin > 1,
            this.loose_inset_px = varargin{1};
          end
          
          this.subplot_resize_fcn
        end % fcn: set_padding
        
        
    end  %Methods
    
    
    methods(Access=private)
        
        function subplot_resize_fcn(this)
            
            %% reset handles in case of loading a saved subplot_grid figure
            try
                if ~sum(ishandle(this.hax(:))),
                    this.reset_handles;
                end
                
                if sum(this.zoomed(:)), % if: anything zoomed
                    Izoomed = find(this.zoomed); % all zoomed-in subplots
                    axpos_out = get(this.hax(Izoomed(1)),'OuterPosition');
                    set(this.hax(Izoomed(1)),'OuterPosition',this.subplotzoom_data(Izoomed(1)).axpos_in);
                end
                
                this.resize_wo_legend;
                
                
                %% determine title dimensions
                %%----------------------------------------------------------------------
                
                figtitleheight = 0;
                subfigtitleheight = 0;
                rowtitlewidth = 0;
                coltitleheight = 0;
                rowtitlewidth_old = 0;
                if ~isempty(this.hax_rowtitles),
                    tmp = get(this.hax_rowtitles(1),'Position');
                    rowtitlewidth_old = tmp(:,3);
                    rowtitlewidth = tmp(3);
                end
                if ~isempty(this.hax_coltitles),
                    tmp = get(this.hax_coltitles(1),'Position');
                    coltitleheight = tmp(4);
                end
                
                
                %%  resize figure title
                %%----------------------------------------------------------------
                
                if any(this.hax_figtitle),
                    
                    % temporary set axes to full window
                    set(this.hax_figtitle,'Position',[0 0 1 1]);
                    
                    % get size of text in normalized units
                    htext_figtitle_pos = get(this.htitle,'Extent');
                    figtitleheight = max([htext_figtitle_pos(4),1e-6]);
                    
                    % determine and set new figure title axes dimensions
                    hax_figtitle_pos_new = [0,...
                        1 - figtitleheight,...
                        1,...
                        figtitleheight];
                    set(this.hax_figtitle,...
                        'Position',hax_figtitle_pos_new);
                end
                
                %%  resize subtitle
                %%----------------------------------------------------------------
                if any(this.hax_subfigtitle),
                    
                    set(this.hax_subfigtitle,'Position',[0 0 1 1]);
                    
                    htext_subfigtitle_pos = get(this.hsubtitle,'Extent');
                    subfigtitleheight = max([htext_subfigtitle_pos(4),1e-6]);
                    
                    hax_subfigtitle_pos_new = [0,...
                        1 - figtitleheight - subfigtitleheight,...
                        1,...
                        subfigtitleheight];
                    set(this.hax_subfigtitle,...
                        'Position',hax_subfigtitle_pos_new);
                end
                
                
                %%  determine column title heights
                %%----------------------------------------------------------------
                
                if any(this.hax_coltitles),
                    coltitleheights = zeros(numel(this.hax_coltitles),1);
                    hax_coltitles_pos_old = zeros(numel(this.hax_coltitles),4);
                    for icol = 1:numel(this.hax_coltitles),
                        hax_coltitles_pos_old(icol,:) = get(this.hax_coltitles(icol),'Position');
                        % resize to full window
                        set(this.hax_coltitles(icol),'Position',[0 0 1 1]);
                        %  get textbox handle
                        htext_coltitle_pos = get(this.hcoltitles(icol),'Extent');
                        coltitleheights(icol) = htext_coltitle_pos(4);
                    end % for: all columns
                    coltitleheight = max([max(coltitleheights),1e-6]);
                    
                    
                end % if: column titles present ?
                
                
                %%  Determine row title width
                %%----------------------------------------------------------------
                
                if any(this.hax_rowtitles),
                    rowtitlewidths = zeros(numel(this.hax_rowtitles),1);
                    hax_rowtitles_pos_old = zeros(numel(this.hax_rowtitles),4);
                    for irow = 1:numel(this.hax_rowtitles),
                        hax_rowtitles_pos_old(irow,:) = get(this.hax_rowtitles(irow),'Position');
                        % resize to full window
                        set(this.hax_rowtitles(irow),'Position',[0 0 1 1]);
                        %  get textbox handle
                        htext_rowtitle_pos = get(this.hrowtitles(irow),'Extent');
                        rowtitlewidths(irow) = htext_rowtitle_pos(3);
                    end % for: all rows
                    rowtitlewidth = max([max(rowtitlewidths),1e-6]);
                end % if: row titles present ?
                
                %% resize subplots
                %%-------------------------------------------------------------------
                vleftover = 1 - figtitleheight - coltitleheight - subfigtitleheight;
                hleftover = 1 - rowtitlewidth;
                
                % determine plot box dimensions
                boxheight_new = vleftover/this.nof_rows;
                boxwidth_new = hleftover/this.nof_columns;
                
                %% mod subplot dimensions
                %%------------------------------------------------------------------------
                % reset subplots
                for ir = 1:this.nof_rows,
                  for ic = 1:this.nof_columns,
                    % reset sizes
                    if ishandle(this.hax(ir,ic)),
                      set(this.hax(ir,ic),'OuterPosition',this.subplotzoom_data(ir,ic).axpos_in);
                      set(this.hax(ir,ic),'Units','pixels','LooseInset',this.loose_inset_px); % Undocumented Matlab
                      set(this.hax(ir,ic),'Units','normalized');
                    end
                  end
                end
                
                haxu = unique(this.hax);
                haxu(isnan(haxu)) = [];
                if numel(haxu) > 1,
                  allpositions = cell2mat(get(haxu,'OuterPosition'));
                else
                  allpositions = get(haxu,'OuterPosition');
                end
                
                minwidth = min(allpositions(:,3));
                minheight = min(allpositions(:,4));
                for ir = 1:this.nof_rows,
                  for ic = 1:this.nof_columns,
                    if ishandle(this.hax(ir,ic)),
                      % get old position
                      pos_old = get(this.hax(ir,ic),'OuterPosition');
                      nof_col_boxes = round(pos_old(3)/minwidth);
                      nof_row_boxes = round(pos_old(4)/minheight);
                      rowstart = round((pos_old(2))/minheight);
                      colstart = round((pos_old(1)-rowtitlewidth_old)/minwidth);

                      pos_new = [rowtitlewidth + (colstart)*boxwidth_new,...
                                 rowstart*boxheight_new,...
                                 nof_col_boxes*boxwidth_new,...
                                 nof_row_boxes*boxheight_new];
                      set(this.hax(ir,ic),'OuterPosition',pos_new,'ActivePositionProperty','OuterPosition');
                      this.subplotzoom_data(ir,ic).axpos_in = get(this.hax(ir,ic),'OuterPosition');
                    end
                  end
                end
                
                
                
                %%  resize row titles again
                %%----------------------------------------------------------------
                
                if any(this.hax_rowtitles),
                    for irow = 1:numel(this.hax_rowtitles),
                        % save old axes position
                        
                        % determine and set new column title axes dimensions
                        hax_rowtitle_pos_new = [0,...
                            (irow - 1)*boxheight_new,...
                            rowtitlewidth,...
                            boxheight_new];
                        set(this.hax_rowtitles(irow),...
                            'Position',hax_rowtitle_pos_new);
                        
                    end % for: all rows
                end % if: row titles present ?
                
                
                %%  resize column titles again
                %%----------------------------------------------------------------
                if any(this.hax_coltitles),
                    for icol = 1:numel(this.hax_coltitles),
                        
                        % determine and set new column title axes dimensions
                        hax_coltitle_pos_new = [rowtitlewidth + (icol-1)*boxwidth_new,...
                            1 - figtitleheight - coltitleheight - subfigtitleheight,...
                            boxwidth_new,...
                            coltitleheight];
                        set(this.hax_coltitles(icol),...
                            'Position',hax_coltitle_pos_new);
                        
                    end
                end
                
                %% Store new axes positions
                %%-------------------------------------------------------------
                
                this.store_axis_positions;
                
                %% redo zoom
                %%-------------------------------------------------------------
                
                if sum(this.zoomed(:)), % if: anything zoomed
                  set(this.hax(Izoomed),'OuterPosition',axpos_out);
                  set(this.hax(Izoomed),'Units','pixels','LooseInset',this.loose_inset_px);
                  set(this.hax(Izoomed),'Units','normalized');
                end
                
                %% reposition zoom buttons
                %%---------------------------------------------------------------
                for ir = 1:this.nof_rows,
                  for ic = 1:this.nof_columns,
                    if ishandle(this.hlegend(ir,ic)),
                      this.place_legend(ir,ic);
                    end
                  end
                end
                drawnow;
                
                for ir = 1:this.nof_rows,
                  for ic = 1:this.nof_columns,
                    if ishandle(this.hcolorbar(ir,ic)),
                      this.place_colorbar(ir,ic);
                    end
                  end
                end
                drawnow;

                
                for ir = 1:this.nof_rows,
                  for ic = 1:this.nof_columns,
                    this.set_zoom_button_position(ir,ic);
                  end
                end

                this.set_gca;
                drawnow;
                
            catch ME
                rethrow(ME);
            end
        end % fcn
        
        
        function place_legend(this,ir,ic,varargin)
            
            if nargin > 3,
                this.legend_data{ir,ic}.location = varargin{1};
                pause(0.2);
            end
            
            
            legend_buffer = 5; % pixels
            if ishandle(this.hlegend(ir,ic)),
              ax_parent = this.hax(ir,ic);
              if this.zoomed(ir,ic),
                handleax = this.hax(:);
                opos = [inf inf 0 0];
                for iax = 1:numel(handleax),
                  if ishandle(this.hax(iax)),
                    cpos = get(this.hax(iax),'OuterPosition');
                    opos(1) = min(opos(1),cpos(1));
                    opos(2) = min(opos(2),cpos(2));
                    opos(3) = max(opos(3),cpos(1)+cpos(3));
                    opos(4) = max(opos(4),cpos(2) + cpos(4));
                  end
                end % for: all axes
                set(ax_parent,'OuterPosition',opos);
              else
                set(ax_parent,'OuterPosition',this.subplotzoom_data(ir,ic).axpos_in); % reset size
              end
              set(ax_parent,'Units','pixels','LooseInset',this.loose_inset_px);
              legpos = get(this.hlegend(ir,ic),'Position');
              axpos = get(ax_parent,'OuterPosition');
              if any(strfind(lower(this.legend_data{ir,ic}.location),'outside')),
                refpos = get(ax_parent,'OuterPosition');
              else
                refpos = get(ax_parent,'Position');
              end

              legpos(1) = round(refpos(1) + (refpos(3)/2) - legpos(3)/2);
              legpos(2) = round(refpos(2) + refpos(4)/2 - legpos(4)/2);
              set(this.hlegend(ir,ic),'Position',legpos);

              if any(strfind(lower(this.legend_data{ir,ic}.location),'outside')),
                axpos_new = axpos;
                if any(strfind(lower(this.legend_data{ir,ic}.location),'north')),
                  legpos(2) = refpos(2) + refpos(4) - legpos(4) - legend_buffer;
                  axpos_new(4) = axpos(4) - legpos(4) - legend_buffer;
                elseif any(strfind(lower(this.legend_data{ir,ic}.location),'south')),
                  legpos(2) = refpos(2) + legend_buffer;
                  axpos_new(2) = axpos(2) + legpos(4) + legend_buffer;
                  axpos_new(4) = axpos(4) - legpos(4) - legend_buffer;
                end
                if any(strfind(lower(this.legend_data{ir,ic}.location),'east')),
                  legpos(1) = refpos(1) + refpos(3) - legpos(3) - legend_buffer;
                  axpos_new(3) = axpos(3) - legpos(3) - legend_buffer;
                elseif any(strfind(lower(this.legend_data{ir,ic}.location),'west')),
                  legpos(1) = refpos(1) + legend_buffer;
                  axpos_new(1) = axpos(1) + legpos(3) + legend_buffer;
                  axpos_new(3) = axpos(3) - legpos(3) + legend_buffer;
                end
                set(ax_parent,'OuterPosition',axpos_new);
                set(ax_parent,'LooseInset',this.loose_inset_px);
                set(ax_parent,'Units','normalized');

              else % else: inside
                if any(strfind(lower(this.legend_data{ir,ic}.location),'north')),
                    legpos(2) = refpos(2) + refpos(4) - legpos(4) - legend_buffer;
                elseif any(strfind(lower(this.legend_data{ir,ic}.location),'south')),
                    legpos(2) = refpos(2) + legend_buffer;
                end
                if any(strfind(lower(this.legend_data{ir,ic}.location),'west')),
                    legpos(1) = refpos(1) + legend_buffer;
                elseif any(strfind(lower(this.legend_data{ir,ic}.location),'east')),
                    legpos(1) = refpos(1) + refpos(3) - legpos(3) - legend_buffer;
                end
                set(ax_parent,'Units','normalized');
              end

              set(this.hlegend(ir,ic),'Position',legpos);

              this.set_zoom_button_position(ir,ic);
              uistack(this.hlegend(ir,ic),'top');
                
            end % if: legend exist for this subplot
            
        end % fcn: place_legend
        
        
        function set_zoom_button_position(this, ir, ic)
          if ~isempty(this.subplotzoom_data(ir,ic)) && ishandle(this.hax(ir,ic)),
            % *** corner ***
            set(this.hax(ir,ic),'units','pixels');     % Set axis units
            pos = get(this.hax(ir,ic),'Position');     % Load current axis position
            corner.x = pos(1)+pos(3)-1;    % X coordinate of top right corner of axis position
            corner.y = pos(2)+pos(4)-1;    % Y coordinate of top right corner of axis position
            set(this.subplotzoom_data(ir,ic).zm_btn,...
                'position',[corner.x-this.zoom_button_size_x corner.y-this.zoom_button_size_y this.zoom_button_size_x this.zoom_button_size_y]);
            uistack(this.subplotzoom_data(ir,ic).zm_btn,'top');
            set(this.subplotzoom_data(ir,ic).zm_btn,'units','pixels');
            set(this.hax(ir,ic),'units','normalized');     % Set axis units
          end
        end
        
        
        function store_axis_positions(this)
            
          for ir = 1 : this.nof_rows
            for ic = 1: this.nof_columns
              if ~isempty(this.subplotzoom_data(ir,ic)) && ishandle(this.hax(ir,ic)),
                this.subplotzoom_data(ir,ic).axpos_in = get(this.hax(ir,ic),'OuterPosition');  % Original axis position of hax [normalized]
              end
            end
          end
        end
        
        
        function subplotzoom_cb(this,foo1,foo2,ir,ic)
            
          if this.zoomed(ir,ic), % if: zoomed-in

              this.show_all_axes_objects;

              % resize active axis
              set(this.hax(ir,ic),'Units','normalized',...
                  'OuterPosition',this.subplotzoom_data(ir,ic).axpos_in); % reset axis
              set(this.hax(ir,ic),'Units','pixels','LooseInset',this.loose_inset_px);
              set(this.hax(ir,ic),'Units','normalized');
              this.set_zoom_button_position(ir,ic); % reset zoom button

              % switch on titles
              set([this.hrowtitles(:);this.hcoltitles(:)],'Visible','on'); % switch on titles

              % set 'zoomed' variable fully to FALSE
              this.zoomed(:) = false;

              % re-hide hidden axes
              for ihidden = 1:numel(this.hidden_axes),
                  [Ir,Ic] = find(this.hax == this.hidden_axes(ihidden));
                  for imerge = 1:numel(Ir),
                      ir = Ir(imerge);
                      ic = Ic(imerge);
                      kids = allchild(this.hax(ir,ic));
                      set([this.hax(ir,ic);kids(isprop(kids,'Visible'))],'Visible','off');
                      set(this.subplotzoom_data(ir,ic).zm_btn,'Visible','off');
                  end
              end

          else % not yet zoomed in

              this.hide_non_zoomed_axes_objects(ir,ic);
%               this.resize_wo_legend;


              % get title dimensions
              figtitleheight = 0;
              subfigtitleheight = 0;
              if any(this.hax_figtitle),
                  posfigtitle = get(this.hax_figtitle,'Position');
                  figtitleheight = posfigtitle(4);
              end
              if any(this.hax_subfigtitle),
                  possubfigtitle = get(this.hax_subfigtitle,'Position');
                  subfigtitleheight = possubfigtitle(4);
              end

              % set leftover pixels
              vleftover = 1 - figtitleheight - subfigtitleheight; % to be modified with figure title

              % maximize and show current axis/button
              set(this.hax(ir,ic),'Units','normalized',...
                  'OuterPosition',[0 0 1 vleftover],...
                  'Visible','on');
              set(this.hax(ir,ic),'Units','pixels','LooseInset',this.loose_inset_px);
              set(this.hax(ir,ic),'Units','normalized');
              uistack(this.hax(ir,ic),'top');
              set(this.subplotzoom_data(ir,ic).zm_btn,'visible','on');
              this.set_zoom_button_position(ir,ic);

              % fill-in 'zoomed' variable
              [Rv,Cv] = find(this.hax == this.hax(ir,ic));
              for iv = 1:numel(Rv),
                  this.subplotzoom_data(Rv(iv),Cv(iv)).zm_btn = this.subplotzoom_data(ir,ic).zm_btn;
                  this.zoomed(Rv(iv),Cv(iv)) = true;
              end

              % switch OFF titles
              set([this.hrowtitles(:);this.hcoltitles(:)],'Visible','off');


          end % ifelse: zoomed in or out??
          this.place_legend(ir,ic);
          
          this.place_colorbar(ir,ic);
        end % fcn: subplotzoom_cb
        
        
        function hide_non_zoomed_axes_objects(this,valid_ir,valid_ic)
            
          for ir = 1:this.nof_rows,
            for ic = 1:this.nof_columns,
              if this.hax(ir,ic) ~= this.hax(valid_ir,valid_ic) && ishandle(this.hax(ir,ic)),
                kids = allchild(this.hax(ir,ic));
                set([this.hax(ir,ic);kids(isprop(kids,'Visible'))],'Visible','off');
                set(this.subplotzoom_data(ir,ic).zm_btn,'Visible','off');
                if ishandle(this.hlegend(ir,ic)),
                  set(cat(1,this.hlegend(ir,ic),allchild(this.hlegend(ir,ic))),'Visible','off');
                end
                if ishandle(this.hcolorbar(ir,ic)),
                  set(cat(1,this.hcolorbar(ir,ic),allchild(this.hcolorbar(ir,ic))),'Visible','off');
                end
                
              end
            end
          end
            
        end
        
        
        function show_all_axes_objects(this)
            
            for ir = 1:this.nof_rows,
              for ic = 1:this.nof_columns,
                if ishandle(this.hax(ir,ic)),
                  kids = allchild(this.hax(ir,ic));
                  set([this.hax(ir,ic);kids(isprop(kids,'Visible'))],'Visible','on');
                  if this.subplotzoom_enabled(ir,ic),
                    set(this.subplotzoom_data(ir,ic).zm_btn,'Visible','on');
                  end
                  if ishandle(this.hlegend(ir,ic)),
                    set(cat(1,this.hlegend(ir,ic),allchild(this.hlegend(ir,ic))),'Visible','on');
                  end
                  if ishandle(this.hcolorbar(ir,ic)),
                    set(cat(1,this.hcolorbar(ir,ic),allchild(this.hcolorbar(ir,ic))),'Visible','on');
                  end
                end
              end
            end
            
        end
        
        
        function interaxes(this,src,evt,ir,ic)
            
            % find current axes
            [interaxes_index] = find([this.interaxes_data(:).axes_handle] == gca);
            
            % find all plot objects which are allowed
            kidstypes = get(allchild(gca),'Type');
            kids = allchild(gca);
            hobjs = kids(ismember(kidstypes,this.interaxes_supported_types));
            
            % remove selection box
            hselbox = findobj(gca,'Tag','selbox');
            hobjs = setdiff(hobjs,hselbox);
            
            % axial ratios
            ylim = get(gca,'YLim');
            xlim = get(gca,'XLim');
            zlim = get(gca,'ZLim');
            xrange = xlim(2) - xlim(1);
            yrange = ylim(2) - ylim(1);
            zrange = zlim(2) - zlim(1);
            axial_ratiox = yrange/xrange;
            axial_ratioz = yrange/zrange;
            clear xrange yrange zrange kidstypes kids
            
            % undo selection properties
            fnames = fieldnames(this.interaxes_data(interaxes_index).local_selection_mods);
            for ifield = 1:numel(fnames),
                if isprop(this.interaxes_data(interaxes_index).selected_object_handle,fnames{ifield}),
                    set(this.interaxes_data(interaxes_index).selected_object_handle,this.interaxes_data(interaxes_index).selected_object_props);
                end
            end
            
            %==============================================================
            % KEY PRESSED
            %==============================================================
            
            if src == this.hfig,
                
                %============== NOTHING SELECTED ======================%
                
                if isnan(this.interaxes_data(interaxes_index).selected_object_handle),
                    % do nothing
                    return
                end
                
                %============== SELECTION EXISTS ======================%
                hsel = this.interaxes_data(interaxes_index).selected_object_handle; % handle of selected on object
                graphtype = get(hsel,'Type');
                
                switch graphtype,
                    
                    
                    %************** KEYPRES - IMAGE/SURFACE ******************
                    
                    case {'image','surface'},
                        
                        xdata = get(hsel,'XData');
                        ydata = get(hsel,'YData');
                        cdata = get(hsel,'CData');
                        if isprop(hsel,'ZData'),
                            zdata = get(hsel,'ZData');
                        end
                        
                        if numel(xdata) == 2,
                            xdata = xdata(1):xdata(2);
                            ydata = ydata(1):ydata(2);
                            [xdata,ydata] = meshgrid(xdata,ydata);
                        end
                        if isvector(xdata),
                            [xdata,ydata] = meshgrid(xdata,ydata);
                        end
                        
                        xpos = get(hselbox,'XData');
                        ypos = get(hselbox,'YData');
                        
                        Ix = find(xdata == xpos);
                        Iy = find(ydata == ypos);
                        
                        [Rthis,Cthis] = ind2sub(size(xdata),intersect(Ix,Iy));
                        Rnew = Rthis;
                        Cnew = Cthis;
                        
                        switch evt.Key
                            case 'leftarrow',
                                if Cthis == 1,
                                    Cnew = size(xdata,2);
                                else
                                    Cnew = Cthis - 1;
                                end
                                
                            case 'rightarrow',
                                if Cthis == size(xdata,2),
                                    Cnew = 1;
                                else
                                    Cnew = Cthis + 1;
                                end
                                
                                
                            case 'uparrow',
                                switch get(gca,'YDir'),
                                    case 'reverse',
                                        if Rthis == 1,
                                            Rnew = size(xdata,1);
                                        else
                                            Rnew = Rthis - 1;
                                        end
                                        
                                    case 'normal',
                                        if Rthis == size(xdata,1),
                                            Rnew = 1;
                                        else
                                            Rnew = Rthis + 1;
                                        end
                                end
                                
                            case 'downarrow',
                                
                                switch get(gca,'YDir'),
                                    case 'reverse',
                                        if Rthis == size(xdata,1);
                                            Rnew = 1;
                                        else
                                            Rnew = Rthis + 1;
                                        end
                                        
                                    case 'normal',
                                        if Rthis == 1;
                                            Rnew = size(xdata,1);
                                        else
                                            Rnew = Rthis - 1;
                                        end
                                end
                                
                            otherwise
                                % do nothing
                                
                        end % switch: key indicator
                        
                        if exist('zdata','var'),
                            posstr = sprintf('Datapoint : [%g ; %g ; %g ; %g]',xdata(Rnew,Cnew),ydata(Rnew,Cnew),zdata(Rnew,Cnew),cdata(Rnew,Cnew));
                        else
                            posstr = sprintf('Datapoint : [%g ; %g ; %g]',xdata(Rnew,Cnew),ydata(Rnew,Cnew),cdata(Rnew,Cnew));
                        end
                        
                        %************** KEYPRES - LINE **************************
                        
                    case {'line'},
                        nof_objs = numel(hobjs);
                        
                        xdata = get(hsel,'XData');
                        ydata = get(hsel,'YData');
                        
                        xdiff = axial_ratiox*(xdata - get(hselbox,'XData'));
                        ydiff = ydata - get(hselbox,'YData');
                        dist = sqrt(xdiff.^2 + ydiff.^2);
                        Ithis = find(dist == min(dist(:)),1);
                        Cnew = Ithis;
                        Rnew = 1;
                        if Ithis == 1,
                            xwindow(1) = -(xdata(Ithis+1) - xdata(Ithis));
                        else
                            xwindow(1) = xdata(Ithis-1) - xdata(Ithis);
                        end
                        if Ithis == numel(xdiff),
                            xwindow(2) = xdata(Ithis) - xdata(Ithis-1);
                        else
                            xwindow(2) = xdata(Ithis+1) - xdata(Ithis);
                        end
                        xwindow = xdata(Ithis) + xwindow;
                        
                        
                        switch evt.Key,
                            
                            case 'leftarrow',
                                Ih = find(xdata >= xlim(1) & xdata <= xlim(2));
                                Iv = find(ydata >= ylim(1) & ydata <= ylim(2));
                                C = intersect(Ih,Iv);
                                Cnew = C(find(C < Ithis,1,'last'));
                                if isempty(Cnew),
                                    Cnew = C(end);
                                end
                                
                                
                                
                                
                            case 'rightarrow',
                                Ih = find(xdata >= xlim(1) & xdata <= xlim(2));
                                Iv = find(ydata >= ylim(1) & ydata <= ylim(2));
                                C = intersect(Ih,Iv);
                                Cnew = C(find(C > Ithis,1,'first'));
                                if isempty(Cnew),
                                    Cnew = C(1);
                                end
                                
                                
                                
                                
                            case 'uparrow', % go to other dataset
                                
                                mindist = inf;
                                iobj_closest = nan; % init
                                for iobj = 1:nof_objs,
                                    % get x/y data
                                    xdata1 = get(hobjs(iobj),'XData');
                                    ydata1 = get(hobjs(iobj),'YData');
                                    [Rvalid,Cvalid] = find(xdata1 > xwindow(1) & xdata1 < xwindow(2) & xdata1 < xlim(2) & xdata1 > xlim(1) & ydata1 > ylim(1) & ydata1 < ylim(2));
                                    Ivalid = sub2ind(size(xdata1),Rvalid,Cvalid);
                                    
                                    if any(Ivalid),
                                        xdata2 = xdata1(Ivalid);
                                        ydata2 = ydata1(Ivalid);
                                        
                                        xdiff = axial_ratiox*(xdata2 - get(hselbox,'XData'));
                                        ydiff = ydata2 - get(hselbox,'YData');
                                        dist = sqrt(xdiff.^2 + ydiff.^2);
                                        [Itmp] = find(dist == min(dist(:)),1,'first');
                                        
                                        Rmin = Rvalid(Itmp);
                                        Cmin = Cvalid(Itmp);
                                        if min(dist(:)) < mindist && ydata2(Itmp) > get(hselbox,'YData'),
                                            mindist = min(dist(:));
                                            iobj_closest = iobj;
                                            Rnew = Rmin;
                                            Cnew = Cmin;
                                            xdata = xdata1;
                                            ydata = ydata1;
                                            
                                        end % if: closer by current selection and above it
                                    end % if: valid points found
                                end % for: all graphics objects
                                
                                % nothing above this point
                                if isnan(iobj_closest),
                                    maxdist = 0;
                                    for iobj = 1:nof_objs,
                                        % get x/y data
                                        xdata1 = get(hobjs(iobj),'XData');
                                        ydata1 = get(hobjs(iobj),'YData');
                                        [Rvalid,Cvalid] = find(xdata1 > xwindow(1) & xdata1 < xwindow(2) & xdata1 <= xlim(2) & xdata1 >= xlim(1) & ydata1 >= ylim(1) & ydata1 <= ylim(2));
                                        if isequal(hobjs(iobj),hsel),
                                            Rvalid(Rnew) = [];
                                            Cvalid(Rnew) = [];
                                        end
                                        
                                        Ivalid = sub2ind(size(xdata1),Rvalid,Cvalid);
                                        if any(Ivalid),
                                            xdata2 = xdata1(Ivalid);
                                            ydata2 = ydata1(Ivalid);
                                            
                                            xdiff = axial_ratiox*(xdata2 - get(hselbox,'XData'));
                                            ydiff = ydata2 - get(hselbox,'YData');
                                            dist = sqrt(xdiff.^2 + ydiff.^2);
                                            [Itmp] = find(dist == max(dist),1);
                                            Rmin = Rvalid(Itmp);
                                            Cmin = Cvalid(Itmp);
                                            if max(dist(:)) > maxdist && ydata2(Itmp) < get(hselbox,'YData'),
                                                maxdist = max(dist(:));
                                                iobj_closest = iobj;
                                                Rnew = Rmin;
                                                Cnew = Cmin;
                                                xdata = xdata1;
                                                ydata = ydata1;
                                                
                                            end % for: all graphics objects
                                        end % if: valid points found
                                    end % for: all graphics objects
                                end % if: nothing above current selection
                                
                                if ~isnan(iobj_closest),
                                    hsel = hobjs(iobj_closest);
                                end
                                
                                
                                
                                
                            case 'downarrow',
                                
                                mindist = inf;
                                iobj_closest = nan; % init
                                for iobj = 1:nof_objs,
                                    % get x/y data
                                    xdata1 = get(hobjs(iobj),'XData');
                                    ydata1 = get(hobjs(iobj),'YData');
                                    [Rvalid,Cvalid] = find(xdata1 > xwindow(1) & xdata1 < xwindow(2) & xdata1 < xlim(2) & xdata1 > xlim(1) & ydata1 > ylim(1) & ydata1 < ylim(2));
                                    Ivalid = sub2ind(size(xdata1),Rvalid,Cvalid);
                                    if any(Ivalid),
                                        xdata2 = xdata1(Ivalid);
                                        ydata2 = ydata1(Ivalid);
                                        
                                        xdiff = axial_ratiox*(xdata2 - get(hselbox,'XData'));
                                        ydiff = ydata2 - get(hselbox,'YData');
                                        dist = sqrt(xdiff.^2 + ydiff.^2);
                                        [Itmp] = find(dist(:) == max(dist(:)),1);
                                        Rmin = Rvalid(Itmp);
                                        Cmin = Cvalid(Itmp);
                                        if min(dist(:)) < mindist && ydata2(Itmp) < get(hselbox,'YData'),
                                            mindist = min(dist(:));
                                            iobj_closest = iobj;
                                            Rnew = Rmin;
                                            Cnew = Cmin;
                                            xdata = xdata1;
                                            ydata = ydata1;
                                        end % if: closer by current selection and above it
                                    end % if: valid points found
                                end % for: all graphics objects
                                
                                % nothing above this point
                                if isnan(iobj_closest),
                                    maxdist = 0;
                                    for iobj = 1:nof_objs,
                                        % get x/y data
                                        xdata1 = get(hobjs(iobj),'XData');
                                        ydata1 = get(hobjs(iobj),'YData');
                                        [Rvalid,Cvalid] = find(xdata1 > xwindow(1) & xdata1 < xwindow(2) & xdata1 <= xlim(2) & xdata1 >= xlim(1) & ydata1 >= ylim(1) & ydata1 <= ylim(2));
                                        if isequal(hobjs(iobj),hsel),
                                            Rvalid(Rnew) = [];
                                            Cvalid(Rnew) = [];
                                        end
                                        Ivalid = sub2ind(size(xdata1),Rvalid,Cvalid);
                                        if any(Ivalid),
                                            xdata2 = xdata1(Ivalid);
                                            ydata2 = ydata1(Ivalid);
                                            
                                            xdiff = axial_ratiox*(xdata2 - get(hselbox,'XData'));
                                            ydiff = ydata2 - get(hselbox,'YData');
                                            dist = sqrt(xdiff.^2 + ydiff.^2);
                                            [Itmp] = find(dist == max(dist),1);
                                            Rmin = Rvalid(Itmp);
                                            Cmin = Cvalid(Itmp);
                                            if max(dist(:)) > maxdist && ydata2(Itmp) > get(hselbox,'YData'),
                                                maxdist = max(dist(:));
                                                iobj_closest = iobj;
                                                Rnew = Rmin;
                                                Cnew = Cmin;
                                                xdata = xdata1;
                                                ydata = ydata1;
                                                
                                            end % for: all graphics objects
                                        end % if: valid points found
                                    end % for: all graphics objects
                                end % if: nothing above current selection
                                
                                if ~isnan(iobj_closest),
                                    hsel = hobjs(iobj_closest);
                                end
                                
                            otherwise
                                
                                % do nothing
                                
                        end % switch: key type
                        
                        posstr = sprintf('Datapoint : [%g ; %g]',xdata(Rnew,Cnew),ydata(Rnew,Cnew));
                        
                    otherwise
                        fprintf(1,'%s is NOT implemented yet\n',upper(graphtype));
                        
                end % switch graph type
                
                
                % modify title string
                ttl = get(get(gca,'Title'),'String');
                ttl{end} = posstr;
                set(get(gca,'Title'),'String',ttl);
                
                % move selection box
                if exist('zdata','var'),
                    set(hselbox,'XData',xdata(Rnew,Cnew),'YData',ydata(Rnew,Cnew),'ZData',zdata(Rnew,Cnew));
                else
                    set(hselbox,'XData',xdata(Rnew,Cnew),'YData',ydata(Rnew,Cnew));
                end
                
                %==============================================================
                % MOUSE CLICK
                %==============================================================
                
                
            else % else: click on axes
                
                set(this.hfig,'CurrentAxes',gca);
                
                % =========== RIGHT MOUSE CLICK ========= %
                
                switch get(this.hfig,'SelectionType'),
                    case 'alt',
                        
                        % delete selection box
                        if any(findobj(gca,'Tag','selbox')),
                            delete(findobj(gca,'Tag','selbox'));
                            
                            % reset title
                            ttl = get(get(gca,'Title'),'String');
                            if strcmp(ttl{end}(1:11),'Datapoint :'),
                                ttl(end) = [];
                                set(get(gca,'Title'),'String',ttl);
                            end
                            
                            % remove current handle selection
                            this.interaxes_data(interaxes_index).selected_object_handle = nan;
                            
                            % set zoom button
                            Icurrent_handle = find(this.hax == this.interaxes_data(interaxes_index).axes_handle);
                            if any(Icurrent_handle),
                                [ir,ic] = ind2sub([this.nof_rows this.nof_columns],Icurrent_handle(1));
                                this.set_zoom_button_position(ir,ic);
                            end
                            return
                        end
                        
                        % =========== LEFT MOUSE CLICK ========= %
                        
                    case 'normal',
                        
                        % point clicked on
                        cp = get(gca,'CurrentPoint');
                        cpx = mean(cp(:,1));
                        cpy = mean(cp(:,2));
                        cpz = mean(cp(:,3));
                        clear cp
                        
                        % what was clicked ?
                        if isempty(gco) || isequal(gco,hselbox),
                            hclicked = gca;
                        else
                            if ismember(get(gco,'Type'),cat(1,'axes',this.interaxes_supported_types)),
                                hclicked = gco;
                            else
                                warning(5,'Ojbects of type ''%s'' are not supported and can not be selected!\nSearching closest valid object point',get(gco,'Type'));
                                hclicked = gca;
                            end
                        end
                        
                        hsel = hclicked; % init
                        
                        if isempty(hclicked),
                            return;
                        end
                        
                        switch get(hclicked,'Type'),
                            case 'surface',
                                xdata = get(gco,'XData');
                                ydata = get(gco,'YData');
                                zdata = get(gco,'ZData');
                                cdata = get(gco,'CData');
                                xdiff = axial_ratiox*(xdata - cpx);
                                ydiff = ydata - cpy;
                                zdiff = axial_ratioz*(zdata - cpz);
                                dist = sqrt(xdiff.^2 + ydiff.^2 + zdiff.^2);
                                Iclosest = find(dist(:) == min(dist(:)),1);
                                
                            case 'image',
                                xdata = get(gco,'XData');
                                ydata = get(gco,'YData');
                                cdata = get(gco,'CData');
                                if numel(xdata) == 2,
                                    xdata = xdata(1):xdata(2);
                                    ydata = ydata(1):ydata(2);
                                end
                                [xdata,ydata] = meshgrid(xdata,ydata);
                                xdiff = axial_ratiox*(xdata - cpx);
                                ydiff = ydata - cpy;
                                dist = sqrt(xdiff.^2 + ydiff.^2);
                                Iclosest = find(dist(:) == min(dist(:)),1);
                                
                                
                            case 'line',
                                xdata = get(hclicked,'XData');
                                ydata = get(hclicked,'YData');
                                xdiff = axial_ratiox*(xdata - cpx);
                                ydiff = ydata - cpy;
                                dist = sqrt(xdiff.^2 + ydiff.^2);
                                Iclosest = find(dist(:) == min(dist(:)),1);
                                
                            case 'axes',
                                % find closest object
                                nof_objs = numel(hobjs);
                                mindist = inf;
                                for iobj = 1:nof_objs,
                                    xdata1 = get(hobjs(iobj),'XData');
                                    ydata1 = get(hobjs(iobj),'YData');
                                    
                                    switch get(hobjs(iobj),'Type'),
                                        
                                        case 'image',
                                            cdata = get(hobjs(iobj),'CData');
                                            if numel(xdata1) == 2,
                                                xdata = xdata1(1):xdata1(2);
                                                ydata = ydata1(1):ydata1(2);
                                            end
                                            [xdata1,ydata1] = meshgrid(xdata1,ydata1);
                                            xdiff = axial_ratiox*(xdata1 - cpx);
                                            ydiff = ydata1 - cpy;
                                            dist = sqrt(xdiff.^2 + ydiff.^2);
                                            
                                        otherwise
                                            
                                            xdata1 = get(hobjs(iobj),'XData');
                                            ydata1 = get(hobjs(iobj),'YData');
                                            xdiff = axial_ratiox*(xdata1 - cpx);
                                            ydiff = ydata1 - cpy;
                                            
                                            zdata1 = get(hobjs(iobj),'ZData');
                                            if isempty(zdata1),
                                                zdata1 = zeros(size(xdata1));
                                            end
                                            zdiff = axial_ratioz*(zdata1 - cpz);
                                            dist = sqrt(xdiff.^2 + ydiff.^2 + zdiff.^2);
                                            
                                    end
                                    
                                    if min(dist(:)) < mindist,
                                        xdata = xdata1(:);
                                        ydata = ydata1(:);
                                        if exist('zdata1','var'),
                                            zdata = zdata1(:);
                                        end
                                        mindist = min(dist(:));
                                        iobj_closest = iobj;
                                        Iclosest = find(dist(:) == min(dist(:)),1);
                                    end
                                    
                                end
                                hsel = hobjs(iobj_closest);
                                if isprop(hsel,'CData'),
                                    cdata = get(hsel,'CData');
                                end
                                
                                
                            otherwise
                                
                                % do nothing, everything is filtered out
                                
                        end % switch: graphics type
                        
                        
                        % create position title string
                        switch get(hsel,'Type'),
                            
                            case {'surface'},
                                posstr = sprintf('Datapoint : [%g ; %g ; %g ; %g]',xdata(Iclosest),ydata(Iclosest),zdata(Iclosest),cdata(Iclosest));
                                
                            case {'image'},
                                posstr = sprintf('Datapoint : [%g ; %g ; %g]',xdata(Iclosest),ydata(Iclosest),cdata(Iclosest));
                                
                            otherwise
                                posstr = sprintf('Datapoint : [%g ; %g]',xdata(Iclosest),ydata(Iclosest));
                        end % switch: selected graphics object
                        
                        % modify title string and location of selection box
                        ttl = get(get(gca,'Title'),'String');
                        if any(hselbox), % if: already something selected
                            ttl{end} = posstr;
                            % move selection box
                            if exist('zdata','var'),
                                set(hselbox,'XData',xdata(Iclosest),'YData',ydata(Iclosest),'ZData',zdata(Iclosest));
                            else
                                set(hselbox,'XData',xdata(Iclosest),'YData',ydata(Iclosest));
                            end
                        else % else: nothing selected yet
                            ttl = cat(1,ttl,posstr);
                            % create selection box
                            if ~ishold,
                                hold on; % toggle ON
                                if exist('zdata','var'),
                                    hselbox = plot3(xdata(Iclosest),ydata(Iclosest),zdata(Iclosest),'ks','MarkerSize',15,'LineWidth',3,'Tag','selbox','ButtonDownFcn',@(src,evt)this.interaxes(src,evt,ir,ic));
                                else
                                    hselbox = plot(xdata(Iclosest),ydata(Iclosest),'ks','MarkerSize',15,'LineWidth',3,'Tag','selbox','ButtonDownFcn',@(src,evt)this.interaxes(src,evt,ir,ic));
                                end
                                hold off; % toggle OFF
                            else
                                hselbox = plot(xdata(Iclosest),ydata(Iclosest),'ks','MarkerSize',15,'LineWidth',3,'Tag','selbox','ButtonDownFcn',@(src,evt)this.interaxes(src,evt,ir,ic));
                            end
                        end % ifelse: anything selected yet ?
                        set(get(gca,'Title'),'String',ttl);
                        
                        
                        
                        % =========== DOUBLE CLICK ========= %
                        
                    case 'open', % double click
                        
                        % not implemented yet
                        
                        
                end % switch: mouse button
                
            end % ifelse: keypress or mouse click?
            
            % correct zoom button position
            this.set_zoom_button_position(ir,ic);
            
            % set and save properties
            this.interaxes_data(interaxes_index).selected_object_handle = hsel;
            modfields = fieldnames(this.interaxes_data(interaxes_index).local_selection_mods);
            for ifield = 1:numel(modfields),
                if isprop(hsel,modfields{ifield}),
                    this.interaxes_data(interaxes_index).selected_object_props.(modfields{ifield}) = get(hsel,modfields{ifield});
                    set(hsel,modfields{ifield},this.interaxes_data(interaxes_index).local_selection_mods.(modfields{ifield}));
                    
                end
            end
            % move object to top of stack
            uistack(hsel,'top');
            uistack(hselbox,'top');
            
        end % fcn
        
        
        function reset_handles(this)
            
            try
                this.hfig = gcf;
                
                % titles
                this.hax_figtitle = findobj(this.hfig,'Type','axes','-and','Tag','figtitle');
                this.htitle = findobj(this.hfig,'Type','text','-and','Tag','figtitle');
                this.hax_subfigtitle = findobj(this.hfig,'Type','axes','-and','Tag','subfigtitle');
                this.hsubtitle = findobj(this.hfig,'Type','text','-and','Tag','subfigtitle');
                hrt = findobj(this.hfig,'Type','axes','-and','Tag','rowtitle');
                trt = findobj(this.hfig,'Type','text','-and','Tag','rowtitle');
                for irt = 1:numel(hrt),
                    ir = get(hrt(irt),'UserData');
                    this.hax_rowtitles(ir) = hrt(irt);
                    ir = get(trt(irt),'UserData');
                    this.hrowtitles(ir) = trt(irt);
                end
                hct = findobj(this.hfig,'Type','axes','-and','Tag','coltitle');
                tct = findobj(this.hfig,'Type','text','-and','Tag','coltitle');
                for ict = 1:numel(hct),
                    ic = get(hct(ict),'UserData');
                    this.hax_rowtitles(ic) = hct(ict);
                    ir = get(tct(irt),'UserData');
                    this.hcoltitles(ir) = tct(irt);
                end
                
                % handles of axes
                haxs = findobj(this.hfig,'Type','axes','-not','Tag','figtitle','-not','Tag','subfigtitle','-not','Tag','coltitle','-not','Tag','rowtitle','-not','Visible','off','-not','Tag','colorbar');
                this.hax = nan(this.nof_rows,this.nof_columns);
                
                positions = cell2mat(get(haxs(:),'OuterPosition'));
                colstarts = unique(positions(:,1));
                rowstarts = sort(unique(positions(:,2)),1,'descend');
                axwidth = min(unique(positions(:,3)));
                axheight = min(unique(positions(:,4)));
                for iax = 1:numel(haxs),
                    pos1 = get(haxs(iax),'OuterPosition');
                    rowspan = round(pos1(4)/axheight);
                    colspan = round(pos1(3)/axwidth);
                    icol = find(colstarts == pos1(1));
                    irow = find(rowstarts == pos1(2));
                    this.hax((1:rowspan) - 1 + irow,(1:colspan) - 1 + icol) = haxs(iax);
                    
                    hzm = findobj(this.hfig,'Type','uicontrol','-and','Tag','subplotzoom','UserData',[irow icol]);
                    Irowzm = (1:rowspan) - 1 + irow;
                    Icolzm = (1:colspan) - 1 + icol;
                    for irowzm = 1:numel(Irowzm),
                        for icolzm = 1:numel(Icolzm),
                            this.subplotzoom_data(Irowzm(irowzm),Icolzm(icolzm)).zm_btn = hzm;
                        end
                    end
                end
                
                % fixed hidden axes
                Inan = find(isnan(this.hax));
                this.hidden_axes = [];
                for inan = 1:numel(Inan),
                    htmp = axes;
                    this.hax(Inan(inan)) = htmp;
                    delete(htmp);
                    this.hidden_axes(inan) = htmp;
                end
                
            catch ME
                rethrow(ME);
            end
        end % fcn
        
        
        function resize_wo_legend(this,varargin)
            
          if nargin > 0, % no inputs
            Iax = 1:this.nof_rows*this.nof_columns;
            [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
            if nargin > 1, % indices
              Iax = varargin{1};
              [Ic,Ir] = ind2sub([this.nof_columns,this.nof_rows],Iax);
              if nargin > 2,
                  Ir = varargin{1};
                  Ic = varargin{2};
              end
            end
          end

          for iter = 1:numel(Ir),
            ir = Ir(iter);
            ic = Ic(iter);
            if ishandle(this.hax(ir,ic)),
              units = get(this.hax(ir,ic),'Units');
              set(this.hax(ir,ic),'Units','normalized','OuterPosition',this.subplotzoom_data(ir,ic).axpos_in);
              set(this.hax(ir,ic),'Units','pixels','LooseInset',this.loose_inset_px);
              set(this.hax(ir,ic),'Units',units);
              if ishandle(this.hcolorbar(ir,ic)),
                this.place_colorbar(ir,ic);
              end
            end % if: handle exists
          end % for: all axes
        end % fcn: resize_wo_legend
        
        
        function delete_axes(this,src,foo)
          [Iax] = find(this.hax == src);
          for iax = 1:numel(Iax),
            [ir,ic] = ind2sub(size(this.hax),Iax(iax));
            this.hax(ir,ic) = nan;
            this.subplotzoom_enabled(ir,ic) = 0;
            if ishandle(this.subplotzoom_data(ir,ic).zm_btn),
              delete(this.subplotzoom_data(ir,ic).zm_btn);
            end
            this.subplotzoom_data(ir,ic).zm_btn = nan;
            if ishandle(this.hlegend(ir,ic)),
              delete(this.hlegend(ir,ic));
              this.hlegend(ir,ic) = nan;
              this.legend_data(ir,ic) = {this.legend_data_struct};
            end
            if ishandle(this.hcolorbar(ir,ic)),
              delete(this.hcolorbar(ir,ic));
            end
          end
          if isequal(gca,findobj(this.hfig,'Type','axes')),
            set(this.hfig,'ResizeFcn',[]);
          end
        end % fcn: delete_axes
        
        
        function place_colorbar(this,ir,ic)
          
          if ishandle(this.hcolorbar(ir,ic)),
            
            hcb_old = this.hcolorbar(ir,ic);
            location = get(hcb_old,'location');
            hcb_new = colorbar('peer',this.hax(ir,ic),location);
            if ishandle(hcb_old),
              delete(hcb_old);
            end
            this.hcolorbar(ir,ic) = hcb_new;
          end
        end % fcn: place_colorbar
        
    end % methods
    
    
    
    
    methods(Static)
        
        function demo
            vpause = 1;
            
            fprintf(1,'=============================================================\n');
            fprintf(1,'\t\tDEMO STARTED\n');
            fprintf(1,'=============================================================\n\n');
            fprintf(1,'Please check the subtitle for information\n\n');
            
            % simple layout
            titlestr = 'Demo of SUBPLOT_GRID function';
            figure;
            curfig = gcf;
            set(curfig,'Units','normalized');
            hsp = subplot_grid(4,5);
            hsp.disable_subplotzoom;
            hsp.figtitle(titlestr,'Interpreter','none');
            pause(vpause);
            
            % add subtitle
            hsp.subfigtitle('Per object a figure title and subtitle can be added');
            pause(vpause);
            
            hsp.subfigtitle('Watch this subtitle for information on what''s happening');
            pause(vpause);
            
            % add row/column titles
            hsp.subfigtitle('Per row multi-line titles may be added');
            rowstr = {'Row title 1';...
                {'Row title 2';'Second line'};...
                '';...
                'Above is empty'};
            hsp.rowtitles(rowstr,'fontsize',8);
            pause(vpause);
            
            % add column titles
            colstr = {'Column 1';...
                'Column 2';...
                {'Column 3';'Sub-column title'};...
                'Another one';...
                {'Title spread out';'over';'3 lines'}};
            hsp.subfigtitle('.. Obviously this also works for columns');
            hsp.coltitles(colstr,'fontsize',8);
            pause(vpause);
            
            % merge subplots
            figure(curfig);clf;
            hsp = subplot_grid(4,5,{[1 7],[10 20],[12 14]});
            hsp.disable_subplotzoom;
            hsp.figtitle(titlestr,'Interpreter','none');
            hsp.subfigtitle('Axes may be merged to create larger axes');
            hsp.rowtitles(rowstr,'fontsize',8);
            hsp.coltitles(colstr,'fontsize',8);
            pause(vpause);
            
            % general resize
            hsp.subfigtitle('General resizing preserves optimal space usage');
            newpos = [0.1 0.1 0.8 0.8];
            set(curfig,'Position',newpos);
            pause(vpause);
            
            % add image
            hsp.subfigtitle('A - tiny - image added to axes (2,3)');
            hsp.set_gca(2,4);
            image;
            axis ij tight;
            title('The matlab example IMAGE');
            pause(vpause)
            
            
            % add subplotzoom
            hsp.subfigtitle({'use SUBPLOTZOOM to expand a single subplot';'Notice the added + button!!'});
            hsp.enable_subplotzoom(2,4);
            pause(vpause);
            
            % zoom tiny image out
            hsp.subfigtitle('Click on +-button to expand subplot');
            hsp.subplotzoom_cb([],[],2,4);
            pause(vpause)
            
            % zoom out again
            hsp.subfigtitle('Clicking again on +-button resets subplot to its original size');
            hsp.subplotzoom_cb([],[],2,4);
            pause(vpause);
            
            % create legend
            hsp.subfigtitle('Creating a legend INSIDE an axes');
            hsp.set_gca(1,1);
            hsp.legend({'r+--';'go';'b.-'},{'Graph 1';'Second thingy';'Final element'},'northeast',1);
            pause(vpause);
            
            % add data to axes
            hsp.subfigtitle('Adding data to the axes matching the legend');
            t = 1:1000;
            s = exp(1j*2*pi*0.01*t);
            n = randn(size(t)) + 1j*randn(size(t));
            s0 = s + 0.05*n;
            f1 = real(s0);
            f2 = imag(s0);
            f3 = abs(s0);
            plot(t,f1,'r+--');hold on;
            plot(t,f2,'go');
            plot(t,f3,'b.-');
            title('Some title string');
            pause(vpause);
            
            % move legend
            hsp.subfigtitle('In this case the legend can be moved outside the axes');
            hsp.relocate_legend('northoutside');
            pause(vpause);
            
            % expansion preserves legend locations
            hsp.subfigtitle('On expansion the legend stays preserved')
            hsp.enable_subplotzoom(1,2);
            hsp.subplotzoom_cb([],[],1,2);
            pause(vpause);
            
            % interaxes
            hsp.subfigtitle('enable INTERAXES function to get values from data points by clicking');
            hsp.enable_interaxes(1,1);
            src = [];
            cp = [0.4570    0.5047];
            set(hsp.hfig,'SelectionType','normal','CurrentPoint',cp)
            hsp.interaxes(src,[],1,1);
            pause(vpause);
            
            % using arrow keys works too
            hsp.subfigtitle('Using the left/right arrow keys scrolls through single graph');
            src = hsp.hfig;
            for iter = 1:10,
                evt.Key = 'leftarrow';
                hsp.interaxes(src,evt,1,1);
                pause(0.5);
            end
            pause(vpause);
            
            % up down keys
            hsp.subfigtitle('Using the up/down arrow keys moves the selection to the closest graph');
            for iter = 1:4,
                evt.Key = 'uparrow';
                hsp.interaxes(src,evt,1,1);
                pause(0.5);
            end
            pause(vpause);
            
            % right click
            hsp.subfigtitle('right-clicking in the axes removes the selection');
            src = [];
            evt = [];
            set(hsp.hfig,'SelectionType','alt');
            hsp.interaxes(src,evt,1,1);
            pause(vpause);
            
            % remove legend
            hsp.subfigtitle('Removing the legend and zooming out');
            hsp.remove_legend(1,1);
            hsp.subplotzoom_cb([],[],1,1);
            pause(vpause);
            
            % demo ended
            hsp.subfigtitle({'DEMO FINISHED!!!';'See help per method for more information'})
            fprintf(1,'=============================================================\n');
            fprintf(1,'\t\tDEMO ENDED\n');
            fprintf(1,'=============================================================\n\n');
        end % fcn
        
    end %methods(Static)
    
end %classdef subplot_grid



