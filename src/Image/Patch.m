classdef Patch < dynamicprops
    
    properties (GetAccess = public, SetAccess = private)
        % Basic properties that every instance of the Patch class has.        
        source_image    %   (Image)           -    Image over which the patch was sampled.
        
        corners         %   (1 x 4 matrix)    -    x-y coordinates wrt. source image, corresponding to the corners 
                        %                          of the rectangular patch. They are [xmin, ymin, xmax, ymax]
    end
       
    methods (Access = public)
        % Class constructror
        function obj = Patch(src_img, corners)
            if nargin == 0
                obj.source_image = Image();
                obj.corners      = zeros(1,4);
            else
                if ~ Patch.valid_corners(corners, src_image)
                    error('The corners of the Patch do not follow the xmin, ymin, xmax, ymax protocol.')
                end
                obj.source_image = src_img;                
                obj.corners      = corners;
                
            end
        end
        
        function [xmin, ymin, xmax, ymax] = get_corners(obj)
            % Getter of object's property 'corners' corresponding to the 4 extema of
            % the x-y coordinates of the patch.
            xmin = obj.corners(1);
            ymin = obj.corners(2);
            xmax = obj.corners(3);
            ymax = obj.corners(4);
        end
    
        function [F] = plot(obj)
         % Plots the boundary of the patch on its source image.
            shape_inserter = vision.ShapeInserter('LineWidth', 4);         
            [xmin, ymin, xmax, ymax] = obj.get_corners();
            rectangle = int32([xmin ymin (xmax - xmax) (ymax - ymin)]);
            im_out    = step(shape_inserter, obj.source_image, rectangle);            
            image(im_out);
        end

        function a = area(obj)
                [xmin, ymin, xmax, ymax] = obj.get_corners();
                a = (ymax-ymin) * (xmax - xmin);
        end
        
        function area = area_of_intersection(obj, another_patch)
            
            [xmin1, ymin1, xmax1, ymax1] = obj.get_corners();
            [xmin2, ymin2, xmax2, ymax2] = another_patch.get_corners();
            
            xmin = max(xmin1, xmin2);
            ymin = max(ymin1, ymin2);
            xmax = min(xmax1, xmax2);
            ymax = min(ymax1, ymax2);
            
            area = max(0, (ymax-ymin) * (xmax-xmin));
        end
            
            
    end
    
    methods (Static, Access = public)
        function [b] = are_valid_corners(corners, src_image)            
            b =  corners(1) <= src_image.width && corners(3) <= src_image.width && ...   % Inside photo's x-dim.
                 corners(2) <= src_image.height && corners(4) <= src_image.height && ...  % Inside photo's y-dim.
                 all(corners) > 0 ;                 
        end
        
        function mask = extract_patch_features(corners, features)
            %TODO fix corner to ints
            mask = zeros(size(features));
            mask(corners(2):corners(4), corners(1):corners(3), :) = features(corners(2):corners(4), corners(1):corners(3), :);
        end
        
        function new_corners = find_new_corners(old_height, old_width, new_height, new_width, old_corners)
            xmin = old_corners(1);
            ymin = old_corners(2);
            xmax = old_corners(3);
            ymax = old_corners(4);
            
            xmin_n = double(xmin) * new_width / old_width;
            xmax_n = double(xmax) * new_width / old_width;
            ymin_n = double(ymin) * new_height/ old_height;
            ymax_n = double(ymax) * new_height/ old_height;
            
            new_corners = [xmin_n ymin_n xmax_n ymax_n];
            new_corners = uint16(ceil(new_corners));
            
        end
        
        
%         function [b] = is_within_area_range(in_patch)
%             w = in_patch.source_image.weight;
%             h = in_patch.source_image.height;
%             [xmin, ymin, xmax, ymax] = in_patch.get_corners();
%             b1 = xmin < 0.01 
%             
%             
%             b1 = boxes(:,1) > feat.imsize(1)*0.01 & boxes(:,3) < feat.imsize(1)*0.99 ...
%             & boxes(:,2) > feat.imsize(2)*0.01 & boxes(:,4) < feat.imsize(2)*0.99;
% bValid2 = boxes(:,1) < feat.imsize(1)*0.01 & boxes(:,3) > feat.imsize(1)*0.99 ...
%         & boxes(:,2) < feat.imsize(2)*0.01 & boxes(:,4) > feat.imsize(2)*0.99;


            
            
            
%         end
         
    end
    
end