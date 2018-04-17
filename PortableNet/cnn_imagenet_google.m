
%CNN_IMAGENET_GOOGLENET  Demonstrates how to use GoogLeNet
tic
% Setup MatConvNet.
run(fullfile(fileparts(mfilename('fullpath')), ...
  '..', '..','practical-cnn-2017a', 'matconvnet','matlab', 'vl_setupnn.m')) ;

modelPath = 'data/googleNet/imagenet-googlenet-dag.mat' ;

if ~exist(modelPath)
  mkdir(fileparts(modelPath)) ;
  urlwrite(...
  'http://www.vlfeat.org/matconvnet/models/imagenet-googlenet-dag.mat', ...
    modelPath) ;
end

net = dagnn.DagNN.loadobj(load(modelPath)) ;

im = imread('1.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
im2 = imread('4.jpg') ;
im2_ = single(im2) ; % note: 255 range
im2_ = imresize(im2_, net.meta.normalization.imageSize(1:2)) ;
im2_ = im2_ - net.meta.normalization.averageImage ;
iim = zeros(224,224,3,2);
iim(:,:,:,1) = im_ ;
iim(:,:,:,2) = im2_ ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('1.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('2.png') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('3.png') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('4.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('5.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('6.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('7.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('8.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('9.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('10.png') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('11.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('12.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('13.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('14.png') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('15.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('16.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('17.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('18.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('19.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('20.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('21.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('22.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('23.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('24.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('25.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('26.png') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('27.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('28.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('29.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

im = imread('30.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;
net.eval({'data', im_}) ;

% show the classification result
scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore) ;

toc
