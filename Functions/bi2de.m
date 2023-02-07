function d = bi2de(b, varargin) 

narginchk(1,3); 
sigStr = ''; 
flag = ''; 
p = []; 

if ~(isnumeric(b) || islogical(b)) 
    error('The binary input must be numeric or logical.'); 
end 
b = double(b);  
 
for i=1:length(varargin) 
   if(i>1) 
      sigStr(size(sigStr,2)+1) = '/'; 
   end 
 
   if(ischar(varargin{i})) 
      sigStr(size(sigStr,2)+1) = 's'; 
   elseif(isnumeric(varargin{i})) 
      sigStr(size(sigStr,2)+1) = 'n'; 
   else 
      error('Optional parameters must be string or numeric.'); 
   end 
end 
 

switch sigStr 
    case '' 
	case 'n' 
      p		= varargin{1}; 
	case 's' 
      flag	= varargin{1};
    case 'n/s' 
      p		= varargin{1}; 
      flag	= varargin{2}; 
	case 's/n' 
      flag	= varargin{1}; 
      p		= varargin{2}; 
   otherwise 
      error('Syntax error.'); 
end 
if isempty(b) 
   error('Required parameter empty.'); 
end 
 
if max(max(b < 0)) || max(max(~isfinite(b))) || (~isreal(b)) || ... 
     (max(max(floor(b) ~= b))) 
    error('Input must contain only finite real positive integers.'); 
end 
if isempty(p) 
    p = 2; 
elseif max(size(p)) > 1 
   error('Source base must be a scalar.'); 
elseif (floor(p) ~= p) || (~isfinite(p)) || (~isreal(p)) 
   error('Source base must be a finite real integer.'); 
elseif p < 2 
   error('Source base must be greater than or equal to two.'); 
end 
if max(max(b)) > (p-1) 
   error('The elements of the matrix are larger than the base can represent.'); 
end 
n = size(b,2); 
if isempty(flag) 
   flag = 'right-msb'; 
elseif ~(strcmp(flag, 'right-msb') || strcmp(flag, 'left-msb')) 
   error('Invalid string flag.'); 
end 

if strcmp(flag, 'left-msb') 
 
   b2 = b; 
   b = b2(:,n:-1:1); 
 
end 
max_length = 1024; 
pow2vector = p.^(0:1:(size(b,2)-1)); 
size_B = min(max_length,size(b,2)); 
d = b(:,1:size_B)*pow2vector(:,1:size_B).'; 
 
idx = find(max(b(:,max_length+1:size(b,2)).') == 1); 
d(idx) = inf; 
 

