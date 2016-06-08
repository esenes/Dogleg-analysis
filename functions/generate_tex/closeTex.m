function [   ] = closeTex( datapath_write, name )
% add the end of the document

texID = fopen([datapath_write filesep name '.tex'], 'a' ); 
cmd = '\\end{document}' ;
fprintf(texID,cmd);
fclose(texID);

end

