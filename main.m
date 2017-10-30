
 %'QUICK TEST - NOT SO RESPONSIVE THO'
[realRes, datArr] = getProcessedData(2);
<<<<<<< HEAD
a = learningParameter(datArr,realRes);
=======
[a] = learningParameter(datArr,realRes);
>>>>>>> refs/remotes/origin/master
bgMatrix = zeros(2,1);
bgMatrix(1,1) = backgroundProbability(realRes , 'student');
bgMatrix(2,1) = backgroundProbability(realRes , 'faculty');
[testRes , testData] = getProcessedData(1);
<<<<<<< HEAD

predictions = cell(1,400);
for i = 1:400
    predictions{1,i} = predict(i , testData , bgMatrix , a);
end
=======
predict1 = predict(276 , testData , bgMatrix , a);
>>>>>>> refs/remotes/origin/master



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

termIndex = 1;
while 1
    if labelArray{termIndex} == 'faculty'
        termIndex = termIndex -1;
        break;
    end
    termIndex = termIndex + 1;
end

classOneSub = dataArray(1:termIndex,:);
answer = zeros(1,1309);
for k = 1:1309
    answer(1,k) = sum( classOneSub{k} );
end
allSum = sum(answer,2);
answer = answer / allSum;
numberOccurMatrix(1,:) = answer;

[r, ~]=size(dataArray);


classTwoSub = dataArray(termIndex:r,:);
answer = zeros(1,1309);
for k = 1:1309
    answer(1,k) = sum( classTwoSub{k} );
end
allSum = sum(answer,2);
answer = answer / allSum;
numberOccurMatrix(2,:) = answer;


numberOccurMatrix = log(numberOccurMatrix);
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

        %log0 * 0 = 0 TODO
        studentProb = studentProb + (dataArray{predictNo,i} * log(probabilityMatrix(1 , i)));
        facultyProb = facultyProb + (dataArray{predictNo,i} * log(probabilityMatrix(2 , i)));
    end 
    studentProb = studentProb + log(backgroundProbability(1,1));
    facultyProb = facultyProb + log(backgroundProbability(2,1));
    
     if(studentProb > facultyProb)
        maxArg = 'student';
     else
        maxArg = 'faculty';
     end
end
