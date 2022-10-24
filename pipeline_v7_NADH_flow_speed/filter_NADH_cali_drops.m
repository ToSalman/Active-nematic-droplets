I1=find(NADH_diameter_greyN025(:,3)<131);
I2=find(NADH_diameter_greyN025(I1,2)>10);
I1(I2,1)
NADH_diameter_greyN025(I1(I2,1),:)=[];