function f=historyUnwrap(data,idx)

    f=zeros(size(data));
    N=length(f);
    f(1:N-idx)=data(idx+1:end);
    f(N-idx+1:end)=data(1:idx);