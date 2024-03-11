f = openfig('C:\Users\NetaS\Google Drive\Neta_Stern\Siemens\Error maps - adiabatic\Error maps - 64 runs for SNR = 50\ABS_T1_testing_Adiabatic_IR_test_TR_2_TI_700_GIR_-0.900_FA_180_ismod_0_DummyScansCount_1_nT2_40_nT1_40.fig');
load('C:\Users\NetaS\Google Drive\Neta_Stern\Siemens\Sim\tse\Adiabatic_IR_test_TR_2_TI_700_GIR_-0.900_FA_180_ismod_0_DummyScansCount_1_nT2_40_nT1_40.mat');

T2_labels = xticklabels;
T1_labels = yticklabels;
B1_labels = B1_scaling_arr;

cur_a = f.Children(11); V(1,:,:) = cur_a.Children.CData';
cur_a = f.Children(9); V(2,:,:) = cur_a.Children.CData';
cur_a = f.Children(7); V(3,:,:) = cur_a.Children.CData';
cur_a = f.Children(5); V(4,:,:) = cur_a.Children.CData';
cur_a = f.Children(3); V(5,:,:) = cur_a.Children.CData';

zslice = [];
yslice = [];

figure;
slice(V,zslice,[1:length(B1_labels)],yslice);
colormap(jet);

dcm_obj = datacursormode(gcf); %datacursor mode on
set(dcm_obj,'enable','on','updatefcn',{@updateMe V T1_tse_arr T2_tse_arr B1_scaling_arr}) %update, need X,Y,Z, f-values

xticks(1:2:40);
yticks(1:5);
zticks(1:2:40);

xticklabels(T2_labels);
yticklabels(B1_labels);
zticklabels(T1_labels);

xlabel('T2 [ms]');
ylabel('B1+');
zlabel('T1 [ms]');

function msg = updateMe(src,evt,f,T1_tse_arr,T2_tse_arr,B1_scaling_arr)
	evt = get(evt); %what's happenin'?
	pos = evt.Position; %position
	fval = f(pos(2),pos(1),pos(3)); %where?
	msg = {sprintf('[x,y,z] = [%d,%d,%d]',pos(1),pos(3),pos(2));...
		   sprintf('[T1,T2,B1+] = [%g,%g,%g]',1000*T1_tse_arr(pos(3)),1000*T2_tse_arr(pos(1)),B1_scaling_arr(pos(2)));...
		   num2str(fval)}; %create msg
end
