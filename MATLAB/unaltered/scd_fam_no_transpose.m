function [ alpha_profile ] = scd_fam_no_transpose(sig, Np, P )
tic
L = Np/4;
N = P*L;

%% Chop into frames

out = zeros(Np, P);
for k = 0:P - 1
    out(:,k + 1) = sig(k*L + 1: k*L + Np);
end

%% First fft + window
window = hamming(Np); %Creates hamming window of length Np

for k = 0:P - 1
    out(:,k + 1) = out(:,k + 1).*window;
    out(:,k + 1) = fft(out(:,k + 1));
    out(:,k+1) = fftshift(out(:,k+1));
end

%out = diag(window)*out; %Multiplies each row by hamming window
%out = fftshift(fft(out)); %FFT

%% Down conversion
[k, m] = meshgrid(0:P - 1, -Np/2:Np/2 - 1);
out = out.*exp(-1j*2*pi.*k.*m.*L/Np);
% out = transpose(out);

%% Multiplication
scd = zeros(2*N, 2*Np);
p = 0:N/Np;

for f1 = 1:Np
    x1 = out(f1,:);
   for f2 = 1:Np
        x2 = conj(out(f2,:));
        col = (f1 + f2 - 1);
        row = (f1 - f2 + Np)*(N/Np);
        x = abs(fftshift(fft(x1.*x2)));
        scd(row + p, col) = x(p + 1);
        scd(row - p + 1, col) = x(P - p);
    end
end
alpha_profile = max(scd, [], 2);
toc
end

