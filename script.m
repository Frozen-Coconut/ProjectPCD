clear; clc;

% Kematangan pisang kepok dapat diklasifikasikan berdasarkan nilai Hue dari
% warna kulit pisang kepok tersebut. Semakin matang sebuah pisang kepok,
% maka akan semakin kecil nilai huenya. Sebaliknya, semakin mentah sebuah
% pisang kepok, akan semakin besar nilai huenya.

Predict('gambar/1.jpg');

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
    
    % Mengambil bentuk tulang dari gambar agar bisa melihat seberapa rumit
    % pembentuk dari benda pada gambar.
    tulang = bwmorph(Ibw, 'skel', Inf);
    bersih = bwmorph(tulang, 'spur', 20);
    bersih = bwmorph(bersih, 'spur', 20);
    
    % Mengambil properties Area, BoundingBox, panjang, dan lebar objek.
    props = regionprops(Ibw, {'Area','BoundingBox', 'MinorAxisLength', 'MajorAxisLength'});
    
    % Mengambil banyak "pulau" dalam objek
    Ibwlb = bwlabel(Ibw);
    s = max(max(Ibwlb));
    numObj = numel(props);
    
    % Memberikan label prediksi pada image. Diambil nilai Hue 0.23 sebagai
    % batas atas dan 0.05 sebagai batas bawah, nilai di luar batas tersebut
    % menunjukkan bahwa gambar yang diberikan bukan merupakan pisang.
    % Selain dari nilai Hue, juga dicek berdasarkan banyaknya pulau-pulau
    % yang didapat dari Black and White, jika banyak pulau dibawah 50 maka
    % dianggap sebagai pisang. Kemudian, melihat jumlah tulang pembentuk,
    % bahwa jika tulang pembentuk yang ditemukan < 4000, maka benda
    % tersebut termasuk pisang.
    checkRegProp = 1;
    if s < 50 
        sumGambar = sum(sum(bersih));
        if sumGambar < 4000 && sumGambar > 200
            if Ihm > 0.23 || Ihm < 0.005
                label = 'gambar invalid';
            elseif Ihm > 0.14
                label = 'mentah';
            elseif Ihm > 0.13
                label = 'setengah matang';
            elseif Ihm > 0.11
                label = 'matang';
            else
                label = 'terlalu matang';
            end
        else
           label = 'gambar invalid';
           checkRegProp = 0;
        end
    else
        label = 'gambar invalid';
        checkRegProp = 0;
    end
    
    % Mencari Area dari pulau yang terbesar agar bisa didapatkan property
    % dari benda yang menjadi pusat perhatian. Selain itu, juga dicari
    % ratio dari benda tersebut.
    if checkRegProp == 1
        largestIndex = 1;
        for i = 1 : numObj
           if props(i).Area == max([props.Area])
               largestIndex = i;
               picRatio = props(largestIndex).MajorAxisLength/props(largestIndex).MinorAxisLength;
           end
        end
    end
    
    % Ratio dari pisang jika < 2 maka bisa dikatakan bukan pisang karena
    % pisang umumnya memiliki panjang yang lebih besar (lebih dari 2x lipat
    % lebarnya).
    if checkRegProp == 1
        if picRatio < 2 && 1/picRatio < 2
           label = 'gambar invalid'; 
        end
    end
    
    % Menampilkan hasil ke console
    disp(append(filename, ' HSV(', string(Ihm), ', ', string(Ism), ', ', string(Ivm), ') ', label));
    
    % Menampilkan hasil ke figure
    figure('Name', append(filename, ' -> ', label));
    nexttile;
    imshow(I);
    hold on;
    if checkRegProp == 1 
       rectangle('Position', props(largestIndex).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 1);
       disp(append('Bounding Box : ', string(props(largestIndex).BoundingBox(1)), ',' , string(props(largestIndex).BoundingBox(2)), ',' ,string(props(largestIndex).BoundingBox(3)), ',' ,string(props(largestIndex).BoundingBox(4)), ','));
       disp(append('Area : ', string(props(largestIndex).Area)));
       disp(append('Major Axis Length : ', string(props(largestIndex).MajorAxisLength)));
       disp(append('Minor Axis Length : ', string(props(largestIndex).MinorAxisLength)));
       disp(append('Ratio : ' , string(picRatio), ' -> inverted : ', string(1/picRatio)));
       disp(append('Largest Index : ', string(largestIndex), ' -> ', string(max([props.Area]))));
       disp(append('objects : ', string(numObj),' <-> ', string(s)))
       disp('');
    end
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
    title(append('Labeled : ', string(s)));
    nexttile;
    imshow(tulang);
    title(append('tulang: ',string(sum(sum(tulang)))));
    nexttile;
    imshow(bersih);
    title(append('bersih: ',string(sum(sum(bersih)))));
end