function [ LH ] = MRF_v5( LH, adj, features, maxIter, th )
%%
%
%   Markov Random Field application over the variables with likelihoods LH
%   and with the edge connections defined by adj.
%
%   INPUT
%       LH -> nxm matrix with each of the variables on the rows and with
%           the likelihoods for each of the classes on the columns.
%       adj -> nxn adjacency matrix with 1 if there is connection and 0 if 
%           there isn't.
%       features -> nxk matrix with features that define each of the 
%           samples. n = num of samples and k = num of features.
%       maxIter -> maximum number of iterations applied to the variables.
%           (optimum for low num of output events: 40)
%       th -> threshold defining the difference that has to be achieved in
%           order to stop the iterative process.
%
%%%%

    [nSamples, nClasses] = size(LH);

    iter = 0;
    converged = false;
    
    while (iter <= maxIter && ~converged)
        %% Ising Model applied
        pLH = LH; % previous LH = pLH
        for i = 1:nSamples
            for j = 1:nClasses
                % If the energy is too high, then we get a similar
                % likelihood to its neighbours
                if(energy(i, j, pLH, adj, features) > 0.5)
                    neighbours = find(adj(i,:));
                    nLen = length(neighbours);
                    LH(i,j) = pLH(i,j);
                    for k = neighbours
                        LH(i,j) = LH(i,j) + LH(k,j);
                    end
                    LH(i,j) = LH(i,j)/(nLen+1);
                end
            end
            LH(i,:) = LH(i,:) / sum(LH(i,:));
            
        end
        converged = sum(abs(distance(pLH, LH))) <= th;
        iter = iter+1;
    end

end

function E = energy(i, j, LH, adj, features)
    E = 1-LH(i,j);
    neighbours = find(adj(i,:));
    lenN = length(neighbours);
    [~, li] = max(LH(i,:));
    for k = neighbours
        [~, lk] = max(LH(k,:));
%         E = E + ( abs( LH(i,j) - LH(k,j) ) * (distance(features(i,:), features(k,:)))  ) / lenN ;
        E = E + ( li==lk * (distance(features(i,:), features(k,:)))  ) / lenN ;
    end
end

function d = distance( X, Y )
%     d = sqrt(sum(X-Y.^2));
    d = sum(abs(X-Y))/length(X);
end

