
%'QUICK TEST - NOT SO RESPONSIVE THO'
[realRes, datArr] = getProcessedData(2);
[a] = learningParameter(datArr,realRes);
bgMatrix = zeros(2,1);
bgMatrix(1,1) = backgroundProbability(realRes , 'student');
bgMatrix(2,1) = backgroundProbability(realRes , 'faculty');
[testRes , testData] = getProcessedData(1);


%prediction1 = predict(1 , datArr , bgMatrix , a);
predictions = cell(1,400);
for i = 1:1000
    predictions{1,i} = predict(i , datArr , bgMatrix , a);
end

cm = confusionMatrix(realRes , predictions);

% xlswrite('arr.xlsx',datArr);

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
function [numberOccurMatrix] = learningParameter(dataArray, labelArray)
numberOccurMatrix = zeros(2,1309);
dataArrayNumber = cellfun(@str2double,dataArray);

termIndex = 1;
while 1
    if labelArray{termIndex} == 'faculty'
        termIndex = termIndex -1;
        break;
    end
    termIndex = termIndex + 1;
end

classOneSub = dataArrayNumber(1:termIndex,:);
answer = sum(classOneSub);

allSum = sum(answer,2);

answer = answer / allSum;
numberOccurMatrix(1,:) = answer;

[r, ~]=size(dataArray);

classTwoSub = dataArrayNumber(termIndex+1:r,:);
answer = sum(classTwoSub);
allSum = sum(answer,2);
answer = answer / allSum;
numberOccurMatrix(2,:) = answer;
assignin('base', 'logsuzxd', numberOccurMatrix);
end



function bp = backgroundProbability(labelMatrix , label)
[sum , ~] = size(labelMatrix);
labelCount = 0;
for i = 1:sum
    if(labelMatrix{i,1} == label)
        labelCount = labelCount + 1;
    end
end
bp = labelCount/sum;
end

function maxArg = predict(predictNo , dataArray , backgroundProbability , probabilityMatrix)
studentProb = 0;
facultyProb = 0;
for i = 1:1309
    if dataArray{predictNo,i} ~= 0
        if probabilityMatrix(1,i) ~= 0
            studentProb = studentProb + (double(dataArray{predictNo,i}) * log(probabilityMatrix(1 , i)+ 1));
        end
        
        if probabilityMatrix(2,i) ~= 0
            facultyProb = facultyProb + (double(dataArray{predictNo,i}) * log(probabilityMatrix(2 , i)+ 1));
        end
    end
end
%studentProb = studentProb + log(backgroundProbability(1));
%facultyProb = facultyProb + log(backgroundProbability(2));


disp(studentProb > facultyProb);
if(studentProb > facultyProb)
    maxArg = 'student';
else
    maxArg = 'faculty';
end

end

function cm = confusionMatrix(realMatrix , predictionMatrix)
    [r , c]  = size(realMatrix);
    cm = zeros(2,2);
    studentTrue = 0;
    studentFalse = 0;
    facultyTrue = 0;
    facultyFalse = 0;
    for i = 1:r
        for j = 1:c
            if(realMatrix{i,j} == 'student')
                if(predictionMatrix{j,i} == 'student')
                    studentTrue = studentTrue + 1;
                else
                    studentFalse = studentFalse + 1;
                end
            else
                if(predictionMatrix{j,i} == 'faculty')
                    facultyTrue = facultyTrue + 1;
                else
                    facultyFalse = facultyFalse + 1;
                end
            end
        end
    end
    cm(1,1) = studentTrue;
    cm(1,2) = studentFalse;
    cm(2,1) = facultyFalse;
    cm(2,2) = facultyTrue;
end
