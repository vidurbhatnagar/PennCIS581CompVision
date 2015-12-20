function blendedImage = gradientDomainBlend(source,target,mask)
    [imh, imw, nb] = size(source); 

    im=im2double(source);

    dTar=im2double(target);

    im2var = zeros(imh, imw); 
    im2var(1:imh*imw) = 1:imh*imw; 

    blendedImage = zeros(imh,imw,nb);
    blendedImage = double(blendedImage);


    for color=1:nb
        sparse_count = 0;
        s = im(:,:,color);
        T = dTar(:,:,color);
        e = 0;
        for y=1:imh
            for x=1:imw
                if(mask(y,x))
                    e = e+1;
                    sparse_count = sparse_count+1;
                    i(sparse_count) = e;
                    j(sparse_count) = im2var(y,x);
                    va(sparse_count) = 4;
                    sparse_count = sparse_count+1;
                    i(sparse_count) = e;
                    j(sparse_count) = im2var(y-1,x);
                    va(sparse_count) = -1;
                    sparse_count = sparse_count+1;
                    i(sparse_count) = e;
                    j(sparse_count) = im2var(y+1,x);
                    va(sparse_count) = -1;
                    sparse_count = sparse_count+1;
                    i(sparse_count) = e;
                    j(sparse_count) = im2var(y,x-1);
                    va(sparse_count) = -1;
                    sparse_count = sparse_count+1;
                    i(sparse_count) = e;
                    j(sparse_count) = im2var(y,x+1);
                    va(sparse_count) = -1;
                    b(e) = 4*s(y,x)-s(y-1,x)-s(y+1,x)-s(y,x-1)-s(y,x+1);
                else
                    e = e+1;
                    sparse_count = sparse_count+1;
                    i(sparse_count) = e;
                    j(sparse_count) = im2var(y,x);
                    va(sparse_count) = 1;
                    b(e) = T(y,x);
                end
            end
        end

        A = sparse(i,j,va,imh*imw,imh*imw);
        b=b(:);

        v = A\b;

        temp = zeros(imh,imw);
        temp = double(temp);
        temp(:)=v;
        blendedImage(:,:,color) = temp;
    end
end