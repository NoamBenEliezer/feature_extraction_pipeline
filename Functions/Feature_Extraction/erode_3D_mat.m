
function [out_mat] = erode_3D_mat(in_mat, nPx, n_Neighbors)

if (~exist('n_Neighbors','var')) || (n_Neighbors < 1) || (n_Neighbors > 6)
	n_Neighbors = 6;
end

if (nPx <= 0)
	out_mat = in_mat;
	return;
end

m = in_mat;
m = logical(m);

for idx = 1:nPx
	m1 = m;  m1(1:end-1,:,:) = m1(2:end  ,:,:);
	m2 = m;  m2(2:end  ,:,:) = m2(1:end-1,:,:);
	m3 = m;  m3(:,1:end-1,:) = m3(:,2:end  ,:);
	m4 = m;  m4(:,2:end  ,:) = m4(:,1:end-1,:);
	m5 = m;  m5(:,:,1:end-1) = m5(:,:,2:end  );
	m6 = m;  m6(:,:,2:end  ) = m6(:,:,1:end-1);

	m = m1 + m2 + m3 + m4 + m5 + m6;
	m(m  < n_Neighbors) = 0;
	m = logical(m);
end

out_mat = in_mat.*m;

return;

