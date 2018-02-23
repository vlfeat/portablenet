clear all
addpath('../../matconvnet/matlab') ;

netPath = '../../PortableNet/data/googlenet/imagenet-googlenet-dag.mat' ;
net = dagnn.DagNN.loadobj(netPath) ;

run(fullfile(fileparts(mfilename('fullpath')), ...
    '..', '..', '..','practical-cnn-2017a', 'matconvnet','matlab', 'vl_setupnn.m')) ;

net.mode = 'test' ;

% load and preprocess an image
im = imread('peppers.png') ;
im_ = single(im) ; % note: 0-255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage) ;

net.conserveMemory = 1 ;

% run the CNN
net.eval({'data', im_},{'prob', im_}) ;

scores = squeeze(gather(net.vars(end).value)) ;
[bestScore, best] = max(scores) ;
figure(1) ; clf ; imagesc(im) ; axis image ;
title(sprintf('%s (%d), score %.3f',...
    net.meta.classes.description{best}, best, bestScore)) ;
