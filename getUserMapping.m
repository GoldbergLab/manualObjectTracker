function [values, keys] = getUserMapping(keys, prefix, initialValues)
if ~exist('initialValues', 'var')
    initialValues = {};
end
if ~exist('prefix', 'var')
    prefix = 'Key: ';
end
if ~iscell(initialValues)
    error('initialValues must be a cell array');
end

% Fill in missing values if any
for k = length(initialValues)+1:length(keys)
    initialValues{k} = '';
end

prompts = {};
for k = 1:length(keys)
    prompts{k} = [prefix, keys{k}];
end

dlgtitle = 'Modify mapping';
dims = [1 35];
values = inputdlg(prompts,dlgtitle,dims,initialValues);