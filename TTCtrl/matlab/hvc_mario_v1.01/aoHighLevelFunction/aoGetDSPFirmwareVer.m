function data_struct=aoGetDSPFirmwareVer(varargin)
% data_struct=aoGetDSPFirmwareVer([firstDsp],[lastDsp])
% Gests DSP status and returns a struct with 4 fields.
% Author(s): Mario
%
% Copyright 2004-2008 Microgate s.r.l.
% $Revision 0.1 $ $Date: 06/09/2007



firstDsp=0;
lastDsp=0;

if nargin==1
    firstDsp=varargin{1};
    lastDsp=varargin{1};
elseif nargin==2
    firstDsp=varargin{1};
    lastDsp=varargin{2};
end;


data_struct.logic=uint32(mgp_op_rd_sram(firstDsp,lastDsp,1,'0x18171','uint32')/65536);
data_struct.nios=uint32(mgp_op_rd_sram(firstDsp,lastDsp,1,'0x18172','uint32'));
if firstDsp==lastDsp
   data_struct.logicHex=[dec2hex(bitand(uint32(data_struct.logic/256),255),2) '.' ...
                         dec2hex(bitand(uint32(data_struct.logic),255),2)];
   data_struct.niosHex=[dec2hex(bitand(uint32(data_struct.nios/16777216),255),2) '.' ...
                        dec2hex(bitand(uint32(data_struct.nios/65536),255),2) '.' ...
                        dec2hex(bitand(uint32(data_struct.nios),65535),4)];
end