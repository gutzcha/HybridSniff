function ret = reshape_vector(vec, win, overlap, output_class)
% vec = reshape(vec,[],1);
if ~exist('overlap','var')||isempty(overlap)
    overlap = 0;    
end

if ~exist('output_class','var')||isempty(output_class)
    output_class = 'double';    
end


[v_len, n_dum] = size(vec);
if v_len==1 && n_dum>1
    vec = reshape(vec,[],1);
    [v_len, n_dum] = size(vec);
end
hop_len = (win-overlap);
n_hops = floor((v_len-overlap)/hop_len);
ret = zeros(win,n_hops,n_dum);

    
if output_class == "categorical"
    ret = categorical(ret,[0,1]);
end

ind_s=1;
for is = 1:n_hops

    ind_e = ind_s + win -1;

    if ind_e>v_len
        a=1
    end
    v = vec(ind_s:ind_e,:);
    ret(:,is,:) = v;
    ind_s = ind_e + 1 - overlap;
end
end