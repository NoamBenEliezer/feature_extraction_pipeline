function []=Print_3D_maps (curr_T2_map, Plane_2D)

V=curr_T2_map;
z=1:1:size(V,1);

% figure;

% Choose the cutting plane to create a sectional view:
switch Plane_2D
case 'Sagittal'
% % Sagittal slices
h_list = slice(V,[],1:length(z),[]);

case 'Axial'
% Axial slices
h_list = slice(V,[],[],1:length(z));

case 'Coronal'
% % Coronal slices
h_list = slice(V,1:length(z),[],[]);
end

% Plot (intensity = 0 -> transperent pixels)
for i=1:length(h_list)
	h = h_list(i);
	set(h,'alphadata',h.CData ~= 0,'facealpha','flat','EdgeColor','none');
end
