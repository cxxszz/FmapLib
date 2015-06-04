classdef Functional_Map
    % A collection of functions for computing Functional Maps as in the
    % (TODO cite papers).
    
    properties
    end
    
    methods (Static)
        
        function X = sum_of_squared_frobenius_norms(D1, D2, L1, L2, lambda)
            N1 = size(D1,1);
            N2 = size(D2,1);
            A_fixed = D1 * D1' ;
            B = D1 * D2' ;
            X = zeros(N2, N1);
            
            if lambda == 0   %  Un-regularized
                X = zeros(N2, N1);
                X = (A_fixed\B)';
            else
                for I = 1 : N2
                    A = diag(lambda * (L1 - L2(I)) .^ 2) + A_fixed;
                    X(I, :) = A \ B(:, I);
                end
            end
        end
        

        
  
        function X = sum_of_frobenius_norms(D1, D2, L1, L2, lambda)
            % Copyright (C) 2014 Fan Wang.            
            N1 = size(D1, 1);
            N2 = size(D2, 1);
            N1N2 = N1 * N2;
            % cvx_setspath('sedumi');
            z = sparse(N1N2, 1);
            % Variables organized as [x y1 y2 y3]
            % For each term, b, c, At are augmented
            % Structure in At:
            % 0 -1  0   0
            % K 0   0   0
            % 0 0   -1  0
            % K 0   0   0
            % 0 0   0   -1
            % K 0   0   0
            % D1 D2
            
            dim = numel(D2);
            K.q = [1 + dim];
            b   = [z; -1];
            D2t = sparse(D2');
            c   = [0; D2t(:)];
            At = [z' -1;
                  kron(speye(N2), D1') sparse(dim, length(K.q))];

            % L1 L2
            if lambda > 0
                dim = N1N2;
                K.q = [K.q 1 + dim];
                b = [b; -lambda];
                c = [c; 0; z];
                At = [At sparse(size(At, 1), 1);
                    sparse(1, size(At, 2)) -1;
                    diag(kron(ones(N2, 1), L1) - kron(L2, ones(N1, 1))) sparse(dim, length(K.q))];
            end

            % Solve
            [x, y, info] = sedumi(sparse(At), sparse(b), sparse(c), K, struct('fid', 0));
            X = reshape(y(1:N1N2), N1, N2)';
        end
        
        function X = sum_of_squared_frobenius_norms_non_diagonal(D1, D2, L1, L2, lambda)
            N1 = size(D1,1);
            N2 = size(D2,1);
            K = size(D1,2);
            % K is also equal to size(D2,2).
            A_fixed = D1 * D1' ;
            B = D2 * D1' ;
            % The first N2 rows of A_large correspond to the first row of
            % AX', or in other words (a_1)*X', the corresponding B values
            % being the first column of B.
            A_large = kron(A_fixed,eye(N2));
            B_large = B(:);
            for n=1:N1
                for m=1:N2
                    L = zeros(N2,N1);
                    for i=1:N2
                        for j=1:N1
                            switch j
                                case m
                                    switch i
                                        case n
                                            L(i,j) = 2*(sum_square(L1(n,:))-sum_square(L2(:,m))-2*L1(n,n)*L2(m,m)-(L1(n,n)-L2(m,m))^2);
                                        otherwise,
                                            L(i,j) = 2*(L1(j,:)*L1(n,:)'-L2(m,m)*L1(n,j)-L1(n,n)*L1(j,n));
                                    end
                                otherwise,
                                    switch j
                                        case n
                                            L(i,j) = 2*(L2(:,i)'*L2(:,m)-L1(n,n)*L2(i,m)-L2(m,i)*L2(m,m));
                                        otherwise,
                                            L(i,j) = 2*(-L2(m,i)*L1(n,j)-L2(i,m)*L1(j,n));
                                    end
                            end
                        end
                    end
                    
                    A_large((n-1)*N2+m,:) = A_large((n-1)*N2+m,:) + lambda*L(:)';
                end
            end
            
            X_vec = A_large \ B_large;
            X = reshape(X_vec,N2,N1);
        end

    end
    
end

