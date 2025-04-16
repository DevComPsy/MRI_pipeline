function mri = alert(input,mri)

addpath('D:\myDocuments\work\Projects\gen_funct\')

mri.warnings{end+1} = input;
cprintf('SystemCommands',[input '\n']);