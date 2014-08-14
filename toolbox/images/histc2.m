function h = histc2( A, edges, wtMask )
% Multidimensional histogram count with weighted values.
%
% Creates a histogram h of the values in A [n x nd], with edges as
% specified. If nd==1, that is when A is a vector, the resulting histogram
% h is a vector of length nBins, where nBins=length(edges)-1. h(q) contains
% the weighted count of values v in A such that edges(q) <= v < edges(q+1).
% h(nBins) additionally contains the weighted count of values in A such
% that v==edges(nBins+1) -- which is different then how histc treates the
% boundary condition. Finally, h is normalized so that sum(h(:))==1.
%
% It usually makes sense to specify edges explicitly, especially if
% different histograms are going to be compared.  In general, edges must
% have monotonically non-decreasing values.  Also, if the exact bounds are
% unknown then it is convenient to set the first element in edges to -inf
% and the last to inf.  If h = histc2( A, nBins, ...), edges are
% automatically generated and have bins equally spaced between min(A) and
% max(A). That is the edges vector is generated by:
%  edges = linspace( min(A)-eps, max(A)+eps, nBins+1 );
%
% If nd>1, that is when A is a 2d matrix instead of a vector, the created
% histogram is multi-dimensional with dimensions nBins^nd, where each bin
% h(q1,...,qnd) contains the the weighted count of vectors v in A such that
% edges{k}(qk) <= v(k) < edges{k}(qk+1), for k=1,...,nd.  Note that if nd>1
% edges may be a cell vector where each element is a vector of edges or a
% scalar nBins as before.
%
% Each value in A may optionally have an associated weight given by wtMask,
% which should have the same number of elements as A. If not specified, the
% default is wtMask=ones(n,1).
%
% USAGE
%  h = histc2( A, edges, [wtMask] )
%
% INPUTS
%  A           - [n x nd] 2D numeric array
%  edges       - quantization bounds, see above
%  wtMask      - [] length [n] vector of weights
%
% OUTPUTS
%  h           - nd histogram [nBins^nd]
%
% EXAMPLE - 1D histograms
%  A=filterGauss([1000 1000],[],[],0); A=A(:); n=length(A);
%  h1 = histc2( A, 25 );              figure(1); bar(h1);
%  h2 = histc2( A, 25, ones(n,1) );   figure(2); bar(h2);
%  h3 = histc2( A, 25, A );           figure(3); bar(h3);
%
% EXAMPLE - 2D histograms
%  A=filterGauss([1000 1000],[],[],0); A=A(:); n=length(A);
%  h=histc2( [A A], 25 );    figure(1); im(h);  % decreasing along diag
%  h=histc2( [A A], 25, A ); figure(2); im(h);  % constant along diag
%
% See also HISTC, ASSIGNTOBINS, BAR
%
% Piotr's Image&Video Toolbox      Version 2.0
% Copyright 2012 Piotr Dollar.  [pdollar-at-caltech.edu]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the Simplified BSD License [see external/bsd.txt]

if( nargin<3 ); wtMask=[]; end;
if( ~isa(A,'double') ); A=double(A); end;
if( ~ismatrix(A) ); error('A must be a 2 dim array'); end;
[n,nd] = size(A);
if( ~isempty(wtMask) && n~=numel(wtMask) )
  error( 'wtMask must have n elements (A is nxnd)' ); end

if( nd==1 )
  % if nBins given instead of edges calculate edges
  if(length(edges)==1)
    edges = linspace(min(A)-eps,max(A)+eps,edges+1);
  end

  % create 1d histogram
  if(isempty(wtMask))
    h = histc( A, edges );
    h(end-1) = h(end-1)+h(end);
    h = h(1:end-1); h = h / sum(h);
  else
    h = histc2c( A, wtMask, edges );
    h = h / sum(h);
  end

else
  % if nBins given instead of edges calculate edges per dimension
  if( ~iscell(edges ) )
    edges=repmat({edges},[1 nd]);
  elseif( length(edges)~=nd )
    error( 'Illegal dimensions for edges' );
  end
  for i=1:length( edges );
    if(length(edges{i})==1)
      edges{i}=linspace(min(A(:,i))-eps,max(A(:,i))+eps,edges{i}+1);
    end
  end

  % create multidimensional histogram
  if( isempty(wtMask) ); wtMask=ones(1,n); end;
  h = histc2c( A, wtMask, edges{:} );
  h = h / sum(h(:));
end

