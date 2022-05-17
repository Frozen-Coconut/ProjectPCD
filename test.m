clear; clc;

% Kematangan pisang kepok dapat diklasifikasikan berdasarkan nilai Hue dari
% warna kulit pisang kepok tersebut. Semakin matang sebuah pisang kepok,
% maka akan semakin kecil nilai huenya. Sebaliknya, semakin mentah sebuah
% pisang kepok, akan semakin besar nilai huenya.

Predict('1.jpg');
Predict('2.jpg');
Predict('pir.jpg');
Predict('4.jpg');
% Predict('5.jpg');
% Predict('6.jpg');
% Predict('7.jpg');
% Predict('8.jpg');
% Predict('9.jpg');
% Predict('10.jpg');
% Predict('11.jpg');
% Predict('12.jpg');
% Predict('13.jpg');
% Predict('14.jpg');
% Predict('15.jpg');
Predict('16.jpg');
Predict('pisangbanyak1.jpg');
Predict('pisangbanyak2.jpeg');
Predict('pisangbanyak3.jpg');
% Predict('kucing1.jpeg');
% Predict('kucing2.jpg');

function [Ihm, Ism, Ivm] = Predict(filename)
    % Membaca image dan mengubah image menjadi double antara 0 dan 1.
    I = im2double(imread(filename));
    
    % Mengambil nilai RGB dari image.
    Ir = I(:, :, 1);
    Ig = I(:, :, 2);
    Ib = I(:, :, 3);
    
    % Melakukan thresholding pada image untuk membuang background.
    % Thresholding dilakukan menggunakan nilai Blue, karena nilai Blue
    % rendah pada warna kulit pisang.
    Ibw = Ib < graythresh(Ib);
    It = cat(3, Ir .* Ibw, Ig .* Ibw, Ib .* Ibw);
    
    % Mengubah image menjadi bentuk HSV.
    Ihsv = rgb2hsv(It);
    
    % Mengambil nilai HSV dari image.
    Ih = Ihsv(:, :, 1);
    Is = Ihsv(:, :, 2);
    Iv = Ihsv(:, :, 3);
    
    % Mengambil rata-rata nilai HSV dari image tanpa background.
    Ihm = mean2(Ih(Ih > 0));
    Ism = mean2(Is(Ih > 0));
    Ivm = mean2(Iv(Ih > 0));
    
    % coba Shape Detection
    Ibwlb = bwlabel(Ibw)
    
    % Memberikan label prediksi pada image. Diambil nilai Hue 0.23 sebagai
    % batas atas dan 0.05 sebagai batas bawah, nilai di luar batas tersebut
    % atau gambar yang terdeteksi oleh function NotBanana menunjukkan bahwa
    % gambar yang diberikan bukan merupakan pisang.
    if NotBanana(Ibw) || Ihm > 0.23 || Ihm < 0.05
        label = 'bukan pisang / tidak valid';
    elseif Ihm > 0.14
        label = 'mentah';
    elseif Ihm > 0.13
        label = 'setengah matang';
    elseif Ihm > 0.11
        label = 'matang';
    else
        label = 'bukan pisang';
    end
    
    % menampilkan hasil ke console
    disp(append(filename, ' HSV(', string(Ihm), ', ', string(Ism), ', ', string(Ivm), ') ', label));
    % menampilkan hasil ke figure
    figure('Name', append(filename, ' -> ', label));
    nexttile;
    imshow(I);
    title('Original');
    nexttile;
    imshow(Ih);
    title(append('Hue ', string(Ihm)));
    nexttile;
    imshow(Is);
    title(append('Saturation ', string(Ism)));
    nexttile;
    imshow(Iv);
    title(append('Value ', string(Ivm)));
    nexttile;
    imshow(Ibwlb);
    title('Black and White');
end

function NotBanana = NotBanana(Ibw)
    % Melakukan inisialisasi boolean untuk return value
    NotBanana = false;
    
    % Ibw = edge(Ibw);
    % Ibw = bwmorph(Ibw, 'bridge', Inf);
    % Ibw = imfill(Ibw, [round(size(Ibw, 1) / 2), round(size(Ibw, 2) / 2)]);
    % Ibw = bwmorph(Ibw, 'close', 10);
    
    % Melakukan erosi dan dilasi pada image untuk menghilangkan celah
    for c = 1:5
        Ibw = imdilate(Ibw, [1 1 1; 1 1 1; 1 1 1]);
    end
    for c = 1:10
        Ibw = imerode(Ibw, [1 1 1; 1 1 1; 1 1 1]);
    end
    
    % Mengambil tulang dari image
    Ibw = bwmorph(Ibw, 'skel', Inf);
    
    % Melabeli image yang sudah ditulangkan untuk menghitung jumlah pulau
    Ibw = bwlabel(Ibw);
    
    % Melakukan pengecekan
    if max(max(Ibw)) ~= 1
        NotBanana = true;
    end
end
