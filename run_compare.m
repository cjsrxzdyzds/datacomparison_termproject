try
 img1='data/Desert.gif';
 img2='data/Sky and birds.gif';
 [X1,map1]=imread(img1);
 if ~isempty(map1)
 RGB=ind2rgb(X1,map1);
 I1=uint8(255*(0.2989*RGB(:,:,1)+0.5870*RGB(:,:,2)+0.1140*RGB(:,:,3)));
 else
 I1=X1;
 end
 [X2,map2]=imread(img2);
 if ~isempty(map2)
 RGB=ind2rgb(X2,map2);
 I2=uint8(255*(0.2989*RGB(:,:,1)+0.5870*RGB(:,:,2)+0.1140*RGB(:,:,3)));
 else
 I2=X2;
 end
 h=figure('Visible','off');
 subplot(2,2,1); imshow(I1); title('Desert');
 subplot(2,2,2); histogram(I1,0:255,'FaceColor','r','EdgeColor','none'); title('Hist Desert'); xlim([0 255]);
 subplot(2,2,3); imshow(I2); title('Sky');
 subplot(2,2,4); histogram(I2,0:255,'FaceColor','b','EdgeColor','none'); title('Hist Sky'); xlim([0 255]);
 saveas(h,'images/image_comparison.png');
 disp('Saved');
 catch ME
 disp(ME.message);