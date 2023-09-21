function MultiTable(n)
    for i = (1:n)
        for j = (1:n)
        fprintf('%i\t',i*j);
        end
    fprintf('\n');
    end
end
