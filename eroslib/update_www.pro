pro update_www

cd, '~/idl/catalog/'
fl = findfile('*.pro')
mk_html_help, fl, 'catalog.html'
cd, '~/idl/lib/'
fl = findfile('*.pro')
mk_html_help, fl, 'lib.html'
cd, '~/idl/glib/'
fl = findfile('*.pro')
mk_html_help, fl, 'glib.html'
cd, '~/idl/scf/'
fl = findfile('*.pro')
mk_html_help, fl, 'scf.html'

  return
end
