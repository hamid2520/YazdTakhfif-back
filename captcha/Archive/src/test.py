import predict
from os import listdir
from os.path import isfile, isdir, join

letters = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
cnt = 0
error_mat = {}
for l1 in letters:
    error_mat[l1] = {}
    for l2 in letters:
        error_mat[l1][l2] = 0

path = 'data/test/'
ind = 1
dsum = 0
for fileName in listdir(path):
    if fileName.split('.')[1] not in ['jpg', 'png']:
        continue
    answer, duration = predict.main(['', '--fname', path + fileName])
    dsum += duration
    correct = fileName.split('.')[0]
    for i in range(len(answer)):
        if answer[i] != correct[i]:
            error_mat[correct[i]][answer[i]] += 1
    if answer == correct:
        cnt += 1
    else: 
        print(ind, answer, correct)
    ind += 1
print(cnt, ind, dsum)
for l1 in letters:
    for l2 in letters:
        if error_mat[l1][l2] != 0:
            print(l1, l2, error_mat[l1][l2])


