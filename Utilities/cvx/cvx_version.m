function [ cvx_ver2, cvx_bld ] = cvx_version
cvx_ver = 1.21;
cvx_bld = '808';
cvx_bdate = '2011-04-17 21:43:47';
cvx_dbld = '806';
cvx_ddate = '2011-02-25 11:00:44';
if nargout == 0,
   fprintf( '\n' );
   fprintf( 'CVX version %g\n', cvx_ver );
   fprintf( '    Code: build %s, %s\n', cvx_bld, cvx_bdate );
   fprintf( '    Documentation: build %s, %s\n', cvx_dbld, cvx_ddate );
   if exist( 'OCTAVE_VERSION', 'var' ),
       fprintf( 'GNU Octave %s on %s\n', version, computer );
       fprintf( 'NOTE: Sorry, Octave support is not yet functional.\n' );
   else
       verd = ver('MATLAB');
       fprintf( 'MATLAB version %s %s on %s\n', verd.Version, verd.Release, computer );
   end
   fprintf( '\n' );
else
    cvx_ver2 = cvx_ver;
end

