function compare_images()
    % Define images
    img1_path = 'data/Desert.gif';
    img2_path = 'data/Sky and birds.gif';

    if ~exist(img1_path, 'file') || ~exist(img2_path, 'file')
        error('Images not found in data/');
    end

    % Read images
    [I1, map1] = imread(img1_path);
    if ~isempty(map1)
        I1 = ind2gray(I1, map1);
    end

    [I2, map2] = imread(img2_path);
    if ~isempty(map2)
        I2 = ind2gray(I2, map2);
    end

    I1 = uint8(I1);
    I2 = uint8(I2);

    h = figure('Visible', 'off', 'Position', [100 100 1200 600]);

    % Image 1
    subplot(2, 2, 1);
    imshow(I1);
    title({'Desert', sprintf('Entropy: %.2f bits', compute_entropy(I1))});

    subplot(2, 2, 2);
    histogram(I1, 0:255, 'EdgeColor', 'none', 'FaceColor', 'r');
    title('Desert Histogram');
    xlim([0 255]);

    % Image 2
    subplot(2, 2, 3);
    imshow(I2);
    title({'Sky and birds', sprintf('Entropy: %.2f bits', compute_entropy(I2))});

    subplot(2, 2, 4);
    histogram(I2, 0:255, 'EdgeColor', 'none', 'FaceColor', 'b');
    title('Sky Histogram');
    xlim([0 255]);

    if ~exist('images', 'dir')
        mkdir('images');
    end
    saveas(h, 'images/image_comparison.png');
    close(h);
end

function H = compute_entropy(img)
    counts = imhist(img);
    p = counts / sum(counts);
    p = p(p > 0);
    H = -sum(p .* log2(p));
end
