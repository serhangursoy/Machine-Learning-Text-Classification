
% QUICK TEST - NOT SO RESPONSIVE THO'
[realRes, datArr] = getProcessedData(1);

% mode = 1 --> TEST
% mode = 2 --> TRAIN
% Might be a little slow :)
function [realResults, DataArray] = getProcessedData(mode)
TEST_PATH  = 'Data/testdata.txt';
TRAIN_PATH = 'Data/traindata.txt';

limit = 399;
if mode == 1
    PATH = TEST_PATH;
else
    PATH = TRAIN_PATH;
    limit = 999;
end
    
testDataSet = fopen(PATH,'r');      % Type, read. Hence, you can't break something :)

rawLine    = fgetl(testDataSet);    % Get line
tempArr    = strsplit(rawLine);     % Temp Array for keeping splitted line.
resultData  = tempArr(:,2:end);     % Don't get first part, its the label. We will check it in another array.
labelArray = tempArr(1,1);          % Get it's label. This is required to check..
for i = 1:limit                     % We already have one, so total-1 iterations left.
    rawLine = fgetl(testDataSet);   
    tempArr = strsplit(rawLine);    
    rowData = tempArr(:,2:end);   
    rowLabel = tempArr(1,1);
    resultData = cat(1,resultData,rowData);     % Concat with starting array.
    labelArray = cat(1,labelArray,rowLabel);    % Concat with starting array
end

realResults = labelArray;
DataArray   = resultData;
clearvars rawLine tempArr labelDataArray tempArrData i TEST_PATH TRAIN_PATH PATH labelArray dataArray limit;
end