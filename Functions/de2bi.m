function b = de2bi(varargin)

narginchk(1,4);
sigStr = '';
msbFlag = '';
p = [];
n = [];

for i=1:nargin
   if(i>1)
      sigStr(size(sigStr,2)+1) = '/';
   end
   if(ischar(varargin{i}))
      sigStr(size(sigStr,2)+1) = 's';
   elseif(isnumeric(varargin{i}))
      sigStr(size(sigStr,2)+1) = 'n';
   else
      error('comm:de2bi:InvalidArg','Only string and numeric arguments are accepted.');
   end
end

switch sigStr
   case 'n'
      d		= varargin{1};
	case 'n/n'
      d		= varargin{1};
      n		= varargin{2};
	case 'n/s'
      d		= varargin{1};
      msbFlag	= varargin{2};
	case 'n/n/s'
      d		= varargin{1};
      n		= varargin{2};
      msbFlag	= varargin{3};
	case 'n/s/n'
      d		= varargin{1};
      msbFlag	= varargin{2};
      n		= varargin{3};
	case 'n/n/n'
      d		= varargin{1};
      n		= varargin{2};
      p  	= varargin{3};
	case 'n/n/n/s'
      d		= varargin{1};
      n		= varargin{2};
      p  	= varargin{3};
      msbFlag	= varargin{4};
	case 'n/n/s/n'
      d		= varargin{1};
      n		= varargin{2};
      msbFlag	= varargin{3};
      p  	= varargin{4};
	case 'n/s/n/n'
      d		= varargin{1};
      msbFlag	= varargin{2};
      n		= varargin{3};
      p  	= varargin{4};
   otherwise
      error('comm:de2bi:InvalidArgSeq','Syntax error.');
end

if isempty(d)
   error('comm:de2bi:NoInput','Required parameter empty.');
end

inType = class(d);
d = double(d(:));
len_d = length(d);

if any(d(:) < 0) || any(~isfinite(d(:))) || ~isreal(d) || ~isequal(floor(d),d)
   error('comm:de2bi:InvalidInput','Input must contain only finite real nonnegative integers.');
end
if isempty(p)
    p = 2;
elseif max(size(p) ~= 1)
   error('comm:de2bi:NonScalarBase','Destination base must be scalar.');
elseif (~isfinite(p)) || (~isreal(p)) || (floor(p) ~= p)
   error('comm:de2bi:InvalidBase','Destination base must be a finite real integer.');
elseif p < 2
   error('comm:de2bi:BaseLessThan2','Cannot convert to a base of less than two.');
end
tmp = max(d);
if tmp ~= 0 				% Want base-p log of tmp.
   ntmp = floor( log(tmp) / log(p) ) + 1;
else 							% Since you can't take log(0).
   ntmp = 1;
end
if ~( (p^ntmp) > tmp )
   ntmp = ntmp + 1;
end
if isempty(n)
   n = ntmp;
elseif max(size(n) ~= 1)
   error('comm:de2bi:NonScalarN','Specified number of columns must be scalar.');
elseif (~isfinite(n)) || (~isreal(n)) || (floor(n) ~= n)
   error('comm:de2bi:InvalidN','Specified number of columns must be a finite real integer.');
elseif n < ntmp
   error('comm:de2bi:SmallN','Specified number of columns in output matrix is too small.');
end
if isempty(msbFlag)
   msbFlag = 'right-msb';
elseif ~(strcmp(msbFlag, 'right-msb') || strcmp(msbFlag, 'left-msb'))
   error('comm:de2bi:InvalidMsbFlag','Invalid string msbFlag.');
end
b = zeros(len_d, n);

if(p==2)
    [~,e]=log2(max(d)); % How many digits do we need to represent the numbers?
    b=rem(floor(d*pow2(1-max(n,e):0)),p);
    if strcmp(msbFlag, 'right-msb')
        b = fliplr(b);
    end
else
    for i = 1 : len_d                  
        j = 1;
        tmp = d(i);
        while (j <= n) && (tmp > 0)     
            b(i, j) = rem(tmp, p);      
            tmp = floor(tmp/p);
            j = j + 1;
        end
    end
    if strcmp(msbFlag, 'left-msb')
        b2 = b;
        b = b2(:,n:-1:1);
    end
end

b = feval(inType, b);  

