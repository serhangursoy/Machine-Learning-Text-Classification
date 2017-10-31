

function [accuracyTraining, accuracyTest, cmTraining , cmTest] = main(file_path)

[realRes, datArr] = getProcessedData(2,file_path);
a = learningParameter(datArr,realRes);
bgMatrix = zeros(2,1);
bgMatrix(1,1) = backgroundProbability(realRes , 'student');
bgMatrix(2,1) = backgroundProbability(realRes , 'faculty');
[testRes , testData] = getProcessedData(1,file_path);

% PREDICT FOR EACH
predictionsTraining = cell(1,1000);
for i = 1:1000
    predictionsTraining{1,i} = predict(i , datArr , bgMatrix , a);
end
cmTraining = confusionMatrix(realRes , predictionsTraining);
% CALCULATE ACCURACY
accuracyTraining = cmTraining(1,1) + cmTraining(2,2);
accuracyTraining = accuracyTraining / (accuracyTraining + cmTraining(1,2) + cmTraining(2,1));

% PREDICT FOR EACH
predictionsTest = cell(1,400);
for i = 1:400
    predictionsTest{1,i} = predict(i , testData , bgMatrix , a);
end
cmTest = confusionMatrix(testRes , predictionsTest);
% CALCULATE ACCURACY
accuracyTest = cmTest(1,1)+cmTest(2,2);
accuracyTest = accuracyTest / (accuracyTest + cmTest(1,2) + cmTest(2,1));

% GET RANKS.
[realRanks ,tops] = rankFeatures(realRes, datArr);

% START PRINTING THE OUTPUT
fileID = fopen('output.txt','wt');
fprintf(fileID,'Accuracy Test: %.5f Accuracy Training: %.5f\n\n', accuracyTest, accuracyTraining);
fprintf(fileID,'Confusion Matrix for Test Data\n');
fprintf(fileID,'%6s %12s\n','Student','Faculty');
fprintf(fileID,'%.2f %.2f\n', cmTest(1,1), cmTest(1,2));
fprintf(fileID,'%.2f %.2f\n\n', cmTest(2,1), cmTest(2,2));
fprintf(fileID,'Confusion Matrix for Train Data\n');
fprintf(fileID,'%6s %12s\n','Student','Faculty');
fprintf(fileID,'%.2f %.2f\n', cmTraining(1,1), cmTraining(1,2));
fprintf(fileID,'%.2f %.2f\n\n', cmTraining(2,1), cmTraining(2,2));
fprintf(fileID,'\nFeature Ranks (From highest rank to lowest)\n');
fprintf(fileID,'Indexes ');
fprintf(fileID,'%6.i ',tops(1,:));
fprintf(fileID,'\nData ');
fprintf(fileID,'%.5f ',tops(2,:));
fclose(fileID);

% UNCOMMENT THIS FOR PLOTTING
% B E W A R E - R E A L L Y   H E A V Y   W O R K!
% plotAccuracy(testData,testRes,realRanks,bgMatrix);


%  FOR THE PLOTTING. IF YOU WANT TO RUN THIS, MAKE SURE YOU HAVE SOME FREE
%  TIME! ITS A HEAVY PROCESS
function none = plotAccuracy(dataArray, labelArray, featureRank, backgroundMatrix)
    
    [~, dataCol] =  size(dataArray);
    
    resultArray = zeros(1,dataCol);
    % Remove min element each time and add to an array for plotting
    for k = 1:dataCol
          [ c , ind] = min(featureRank(1,:));
          tmp1 = dataArray(:,1:ind);
          tmp2 = dataArray(:,ind+1:end);
          dataArray = horzcat(tmp1,tmp2);
          newProbMatrix = learningParameter(dataArray,labelArray);
          preTes = cell(1,400);
          for f = 1:400
              preTes{1,f} = predict(f , dataArray , backgroundMatrix ,newProbMatrix);
          end
          confTes = confusionMatrix(testRes , preTes);
          accuracyTest = confTes(1,1)+confTes(2,2);
          accuracyTest = accuracyTest / (accuracyTest + confTes(1,2) + confTes(2,1));
          resultArray(1,k) = accuracyTest;
    end 
    
    plot(resultArray)
end

% GET PROCESSED DATA
function [realResults, DataArray] = getProcessedData(mode,file_path)
TEST_PATH  = strcat(file_path,'/testdata.txt');
TRAIN_PATH = strcat(file_path,'/traindata.txt');

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

% GET OCCURANCE MATRIX WITH USING LEARNING PARAMETERS
function [numberOccurMatrix] = learningParameter(dataArray, labelArray)
[~, dataColumn] = size(dataArray); 
numberOccurMatrix = zeros(2,dataColumn);
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
end

% CALCULATE BACKGROUND PROBABILITY
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

% PREDICT WITH GIVEN PARAMETERS
function maxArg = predict(predictNo , dataArray , backgroundProbability , probabilityMatrix)
studentProb = 0;
facultyProb = 0;

[~,dataColumn] = size(dataArray);

for i = 1:dataColumn
    if dataArray{predictNo,i} ~= 0
        if probabilityMatrix(1,i) ~= 0
            studentProb = studentProb + (double(dataArray{predictNo,i}) * log(probabilityMatrix(1 , i)+ 1));
        end
        
        if probabilityMatrix(2,i) ~= 0
            facultyProb = facultyProb + (double(dataArray{predictNo,i}) * log(probabilityMatrix(2 , i)+ 1));
        end
    end
end
studentProb = studentProb + log(backgroundProbability(1));
facultyProb = facultyProb + log(backgroundProbability(2));

if(studentProb > facultyProb)
    maxArg = 'student';
else
    maxArg = 'faculty';
end

end

% GET CONFUSION MATRIX
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

% N00 - Its Student but number is something bigger than zero
% N01 - Its Student but number is 0
% N10 - Its Faculty but number is something bigger than zero
% N11 - Its Faculty but number is 0
function [realFutureRanks , top10] = rankFeatures(labelData,dataArray)
featureRanks = zeros(2,1309);
dataArrayNumber = cellfun(@str2double,dataArray);
termIndex = 1;
while 1
    if labelData{termIndex} == 'faculty'
        termIndex = termIndex -1;
        break;
    end
    termIndex = termIndex + 1;
end

N00=0; N01=0; N11=0; N10=0; N=0;
C00=0; C01=0; C11=0; C10=0; C=0;

[h,~] = size(dataArray);

for co = 1:1309
    for ro = 1:h        
        if (dataArrayNumber(ro,co) > 0 && ro<= termIndex)
            N00 = N00 + 1;
            C11 = C11 + 1;
        elseif (dataArrayNumber(ro,co) == 0 && ro<= termIndex)
            N01 = N01 + 1;
            C10 = C10 + 1;
        elseif (dataArrayNumber(ro,co) > 0 && ro > termIndex)
            N10 = N10 + 1;
            C01 = C01 + 1;
        else
            N11 = N11 + 1;
            C00 = C00 + 1;
        end
    end
    
    C = C00 + C01 + C11 + C10;
    N = N00 + N01 + N11 + N10;
    
    ResN = ((N11/N)*log2( (N*N11) / ((N11+N10)*(N01+N11))));
    ResN = ResN + ((N01/N)*log2( (N*N01) / ((N01+N00)*(N01+N11))));
    ResN = ResN + ((N10/N)*log2( (N*N10) / ((N11+N10)*(N10+N00))));
    ResN = ResN + ((N00/N)*log2( (N*N00) / ((N01+N00)*(N10+N00))));
    
    ResC = ((C11/C)*log2( (C*C11) / ((C11+C10)*(C01+C11))));
    ResC = ResC + ((C01/C)*log2( (C*C01) / ((C01+C00)*(C01+C11))));
    ResC = ResC + ((C10/C)*log2( (C*C10) / ((C11+C10)*(C10+C00))));
    ResC = ResC + ((C00/C)*log2( (C*C00) / ((C01+C00)*(C10+C00))));
    
    featureRanks(1,co) = ResN;
    featureRanks(2,co) = ResC;
end
    realFutureRanks = featureRanks;
    
    top10 = zeros(2,10);
    for a = 1:10
        [ c , ind] = max(featureRanks(1,:));
        top10(1,a) = ind;
        top10(2,a) = c;
        featureRanks(1,ind) = -c;
    end
end

end

