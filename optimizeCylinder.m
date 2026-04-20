function [optimal_alpha, optimal_beta] = optimizeCylinder(n,r,f_handle)

    % Objective function
    function obj = objectiveFunction(vars)
        
        alpha = vars(1:n);
        beta  = vars(n+1:end);

        lx = diff(alpha);
        ly = diff(beta);

        % ---- Original objective terms ----
        obj0 = sum((-alpha(1:n-1) + alpha(2:n) - (1/n)).^2) + ...
               sum((-beta(1:n-1)  + beta(2:n)  - (1/n)).^2) + ...
               sum((lx(2:end) - lx(1:end-1)).^2) + ...
               sum((ly(2:end) - ly(1:end-1)).^2);

        % ---- Fundamental form (currently OFF) ----
        ai = alpha(2:n-1);
        bi = beta(2:n-1);

        dx = alpha(3:n) - alpha(2:n-1);
        dy = beta(3:n)  - beta(2:n-1);

        E = (dx.^2 + dy.^2);
        G = ones(size(E));
        F = zeros(size(E));

        loss_I = sum((E - 1).^2) + sum((F - 0).^2) + sum((G - 1).^2);

        d2x = alpha(3:n) - 2*alpha(2:n-1) + alpha(1:n-2);
        d2y = beta(3:n)  - 2*beta(2:n-1)  + beta(1:n-2);

        eps_val = 1e-8;
        norm_xy = sqrt(ai.^2 + (bi - 1).^2);
        norm_xy = max(norm_xy, eps_val);

        nx = ai ./ norm_xy;
        ny = (bi - 1) ./ norm_xy;

        e = (d2x .* nx + d2y .* ny);

        loss_II = sum((e - 1).^2);

        lambda1 = 0;
        lambda2 = 0;

        obj = obj0 + lambda1*loss_I + lambda2*loss_II;
    end

    % Bounds
    lb=[0*ones(1,n),(1-r)*ones(1,n)];
    ub=[r*ones(1,n),(1)*ones(1,n)];

    % Linear constraints
    A_alpha=zeros(n-1,2*n); 
    A_beta=zeros(n-1,2*n);

    for i=1:n-1
        A_alpha(i,i)=1; A_alpha(i,i+1)=-1;
        A_beta(i,n+i)=1; A_beta(i,n+i+1)=-1;
    end

    A=[A_alpha;A_beta]; 
    b=zeros(2*(n-1),1);

    % Boundary conditions
    Aeq=zeros(4,2*n);
    Aeq(1,1)=1;
    Aeq(2,n+1)=1;
    Aeq(3,n)=1;
    Aeq(4,2*n)=1;

    beq=[0;1-r;r;1];

    options=optimoptions('fmincon','Display','off','Algorithm','sqp');

    % Nonlinear constraint
    nonlcon=@(vars)deal([],f_handle(vars(1:n),r)-vars(n+1:end));

    init_vars=0.5*ones(1,2*n)*(r);

    [optimal_vars,final_loss]=fmincon(@objectiveFunction,...
                           init_vars,A,b,Aeq,beq,...
                           lb,ub,...
                           nonlcon,...
                           options);

    disp(['Final loss value: ', num2str(final_loss)]);

    optimal_alpha=optimal_vars(1:n);
    optimal_beta=optimal_vars(n+1:end);

    % >>> SHIFT RESULT <<<
    shift = 10;
    optimal_alpha = optimal_alpha + 0*shift;
    optimal_beta  = abs(5*optimal_beta)  + 2*shift;

end
