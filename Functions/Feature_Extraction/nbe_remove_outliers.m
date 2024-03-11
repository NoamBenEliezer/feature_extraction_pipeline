% Change points that reside outside mean +- N x STD of original data to
% ignored_value

function out_mat = nbe_remove_outliers(mat,nSD,ignored_val)
if (isempty(mat) || (nSD <= 0))
	out_mat = mat;
	return;
else
    out_mat = mat;
end

tmp_mat = mat;
tmp_mat = tmp_mat(:);
tmp_mean = mean(tmp_mat(tmp_mat~=ignored_val));
tmp_sd   =  std(tmp_mat(tmp_mat~=ignored_val));

out_mat(out_mat < (tmp_mean - nSD*tmp_sd)) = ignored_val;
out_mat(out_mat > (tmp_mean + nSD*tmp_sd)) = ignored_val;

return;

% out_mat = out_mat(out_mat~=ignored_val);



% [NBE] delete min max, not relevant, make useful for 3d array, leave only outlier removal.
% commented line 11 (remove ignored values) and 14-15 (validate the value range).
% the rest is outlier removal. I think it's fine for 3D...