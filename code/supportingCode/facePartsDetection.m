clear all;
close all;
%BEFORE RUNNING this code create 5 folders faces, righteye,lefteye,nose,mouth, eyebrow in ur G:/ drive 
faceDetect = vision.CascadeObjectDetector();
eyeDetect = vision.CascadeObjectDetector('RightEye');
ndetect=vision.CascadeObjectDetector('Nose','MergeThreshold',16);
mdetect=vision.CascadeObjectDetector('Mouth','MergeThreshold' ,20);
modetect=vision.CascadeObjectDetector('Mouth');

% foldername=dir('C:\Users\sivaram\Documents\MATLAB\MyCreations\*.jpg');% Enter the path to folder that has .tiff face images
for k1=1:length(foldername)
% filename=strcat('C:\Users\sivaram\Documents\MATLAB\MyCreations\',foldername(k1).name); %Enter the path to folder
Image=imread('test.jpg');
if (size(Image, 3) ==3)
	Image=rgb2gray(Image);
end

bbox=step(faceDetect,Image);
if size(bbox(:,1))>0
	bbox(1,2)=bbox(1,2)+20;
	face=imcrop(Image,bbox(1,:));
	centerx=size(face,1)/2;
	centery=size(face,2)/2;
	half=imcrop(face,[1,1,bbox(1,3),centery]);
	imwrite(face,strcat('G:\faces\',foldername(k1).name));
	
	eyebox=step(eyeDetect,half);
	n=size(eyebox,1);
	if(n>2)
     
		for it=2:size(eyebox,1)
			if ~(abs(eyebox(1,2)-eyebox(it,2))>8)
				 eyebox(2,:)=eyebox(it,:);
				 break;
			 end
		end
 
		re=imcrop(face,eyebox(1,:));
 
		le=imcrop(face,eyebox(2,:));
		imwrite(re,strcat('G:\righteye\',foldername(k1).name));
		imwrite(le,strcat('G:\lefteye\',foldername(k1).name));
	 else
		if n ==1
		         	re=imcrop(face,eyebox(1,:));
		         	imwrite(re,strcat('G:\righteye\',foldername(k1).name));
			fprintf(strcat(foldername(k1).name,' One eye detected','\n'));
     
		end
		if n == 2
             			re=imcrop(face,eyebox(1,:));
             			le=imcrop(face,eyebox(2,:));
             			imwrite(re,strcat('G:\righteye\',foldername(k1).name));
            			imwrite(le,strcat('G:\lefteye\',foldername(k1).name));
		 end
		if n == 0
			fprintf(strcat(foldername(k1).name,' No eye detected','\n'));
     		end
	 end
 
	
	nosebox=step(ndetect,face);
	if size(nosebox(:,1)~=0)
    		nose=imcrop(face,nosebox(1,:));
   		imwrite(nose,strcat('G:\nose\',foldername(k1).name));
    		noseCentery=nosebox(1,2)+(nosebox(1,4)/2);
    		m=[1,noseCentery,size(face,1),((size(face,2))-noseCentery)];
    		mouth=imcrop(face,m);

    		
    		mouthbox=step(mdetect,mouth);
    
        		if size(mouthbox,1)>=1
            			ind=find(mouthbox(:,2)==max(mouthbox(:,2)));
            			mouthbox=mouthbox(ind,:);
            			detectedEyeBrow=imcrop(face,[mouthbox(1,1),mouthbox(1,2)-20,mouthbox(1,3),mouthbox(1,4)]);
            			imwrite(detectedEyeBrow,strcat('G:\eyebrow\',foldername(k1).name));
            			mouthbox(1,2)=mouthbox(1,2)+noseCentery;
            			detectedMouth=imcrop(face,[mouthbox(1,1)-20,mouthbox(1,2)-20,mouthbox(1,3)+30,mouthbox(1,4)+30]);
            			imwrite(detectedMouth,strcat('G:\mouth\',foldername(k1).name));
        
        		end
    	else
        		fprintf(strcat(foldername(k1).name,' No nose detected','\n'));
       		 
       		 mouthbox=step(modetect,face);
       		 if size(mouthbox,1)>0 %&& noseCentery ~= 0 
            			ind=find(mouthbox(:,2)==max(mouthbox(:,2)));
            			mouthbox=mouthbox(ind,:);
			detectedEyeBrow=imcrop(face,[mouthbox(1,1),mouthbox(1,2)-noseCentery,mouthbox(1,3),mouthbox(1,4)]);
        			imwrite(detectedEyeBrow,strcat('G:\eyebrow\',foldername(k1).name));
      
        			detectedMouth=imcrop(face,[mouthbox(1,1)-20,mouthbox(1,2)-20,mouthbox(1,3)+30,mouthbox(1,4)+30]);
       		 	imwrite(detectedMouth,strcat('G:\mouth\',foldername(k1).name));
        		else
			fprintf(strcat(foldername(k1).name,' No mouth detected','\n'));
		end
	end

	else
		display('Face not detected');
	end
end
