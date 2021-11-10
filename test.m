
close all
set(0, 'defaultfigurevisible', 'off')
set(0, 'defaultaxesfontsize', 16)

xq = [92, 120];
yq = [55, 35]
qstr = [num2str(xq(1)), '_', num2str(xq(2)), '_', num2str(yq(1)), '_',num2str(yq(2))]

xm = linspace(xq(1), xq(2), 8);
ym = linspace(yq(1), yq(2), 8);
levels = [0.005 0.01 0.04 0.08 0.1 0.2 0.3 0.5 0.7 1.0 1.3 1.7 2.1 2.7 3.3 4.1 4.9 5.9 6.9 8.2 9.5 11.0 12.6 14.5 16.4 18.6 20.9 23.5 26.2 29 32 36 39 43 47 52 56 61 66 72 77 83 90 96 103 110 118 126 134 142 151 160 170 180 190 200 212 223 235 247 260 273 286 300 314 329 344 359 375 391 407 424 442 460 478 497 516 535 555 576 596 617 639 661 685 707 730 754 778 802 827 853 879 905 932 958 986 1014 1042 1071 1100];
lat = (1:551)*0.1;
lon = (1:1101)*0.1+45;
[yy, xx] = meshgrid(lat, lon);
infile = './GIIRS_2021110620gird2.dat';
infile0 = './GIIRS_2021110520gird2.dat';

if ~exist([infile0,'.mat'], 'file')  
    % {{{
    fileID = fopen(infile0, 'r');
    A = fread(fileID, 1101*551*101, 'single');
    fclose(fileID);
    A(A == -999999) = nan;
    A = reshape(A, 1101,551,101)-273.15;
    for iz = 1:size(A, 3)
        disp(levels(iz))
        if levels(iz) >= 300 & levels(iz) <= 853 
            t = A(:,:,iz);
            t1 = griddata(xx(~isnan(t)), yy(~isnan(t)),...
                t(~isnan(t)), xx, yy);
            t0 = griddata(xx(~isnan(t)), yy(~isnan(t)),...
                t(~isnan(t)), xx, yy, 'nearest');
            t1(isnan(t1)) = t0(isnan(t1));
            A(:,:,iz) = t1;
        end
    end
    save([infile0,'.mat'], 'A')
    B = A;
else 
    load([infile0,'.mat'])
    B = A;
end  % }}} 

if ~exist([infile,'.mat'], 'file')
    % {{{
    fileID = fopen(infile, 'r');
    A = fread(fileID, 1101*551*101, 'single');
    fclose(fileID);
    A(A == -999999) = nan;
    A = reshape(A, 1101,551,101)-273.15;
    for iz = 1:size(A, 3)
        disp(levels(iz))
        if levels(iz) >= 300 & levels(iz) <= 853 
            t = A(:,:,iz);
            t1 = griddata(xx(~isnan(t)), yy(~isnan(t)),...
                t(~isnan(t)), xx, yy);
            t0 = griddata(xx(~isnan(t)), yy(~isnan(t)),...
                t(~isnan(t)), xx, yy, 'nearest');
            t1(isnan(t1)) = t0(isnan(t1));
            A(:,:,iz) = t1;
        end
    end
    save([infile,'.mat'], 'A')
else 
    load([infile,'.mat'])
end % }}} 

ccc = jet(128);
jet2 = ccc(1:64, :);

if dt == 1
    A = A - B;
    A(A > -1) = nan;
end
clear B


levs = [300, 497, 707, 853];
slev = [300, 500, 700, 850];

[xm2, zm2] = meshgrid(xm, interp1(1:4, slev, 1:0.25:4));
[ym2, zm2] = meshgrid(ym, interp1(1:4, slev, 1:0.25:4));

[clon, clat] = load_coast;


% cartoon from left to right
if dt >= 1
figure('position', [515   157   570   814])
% {{{
hold on
set(gca, 'zdir', 'reverse', 'xlim', [70,128], 'ylim', [20, 55], 'zlim', [300, 850], 'position', [0.17, 0.15, 0.8, 0.8]) % , 'zscal', 'log')
view(-22, 15)
h = colorbar('location', 'southoutside', 'position', [0.1,0.05, 0.8, 0.02]);
h.Label.String = ' ℃'
h.Label.HorizontalAlignment = 'left'
h.Label.Units = 'Normalized'
h.Label.Position = [1,0.5,0]
xlabel('Longitude')
ylabel('Latitude')
zlabel('Pressure')
colormap(jet2)
caxis([-20, -1])
if dt == 2
    caxis([-40, 20])
    colormap(jet)
end
idz = 853 == levels;
a = A(:,:,idz);
s = surf(xx, yy, xx*0+850, a);
shading flat
c = plot3(clon, clat, clon*0+850, 'k');
k = plot3([70,128, 128, 70, 70], [20, 20, 55, 55, 20], zeros(5)+850, 'k');
[yyy, zzy] = meshgrid(lat, levels);
for ix = 1:10:length(lon)
    if lon(ix) >= 70  && lon(ix) <= 128
        disp(lon(ix))
        s = surf(yyy*0+lon(ix), yyy, zzy, reshape(A(ix,:,:), size(A, 2), size(A,3))');
        shading flat
        k = plot3(zeros(5)+lon(ix),...
            [55, 20, 20, 55, 55], [850, 850, 300, 300, 850], 'k');
        print('-dpng', '-r100', ... 
        [infile, '.',num2str(dt),'.',qstr,...
            '_pq_',num2str(30000+ix),'.png'])
        delete(s)
        delete(k)
    end
end
% }}}
end

% cartoon from down to up
if dt >= 1
figure('position', [515   157   570   814])
% {{{
hold on
set(gca, 'zdir', 'reverse', 'xlim', [70,128], 'ylim', [20, 55], 'zlim', [300, 853], 'position', [0.17, 0.15, 0.8, 0.8]) % , 'zscal', 'log')
view(-22, 15)
h = colorbar('location', 'southoutside', 'position', [0.1,0.05, 0.8, 0.02]);
h.Label.String = ' ℃'
h.Label.HorizontalAlignment = 'left'
h.Label.Units = 'Normalized'
h.Label.Position = [1,0.5,0]
p = plot3(xq, yq, [0,0]+850-1, '-')
set(p, 'color', [1,0,1], 'linewidth', 2)
xlabel('Longitude')
ylabel('Latitude')
zlabel('Pressure')
colormap(jet2)
caxis([-20, -1])
if dt == 2
    caxis([-40, 20])
    colormap(jet)
end
for ilev = length(levels):-1:1
    lev = levels(ilev)
    if lev >= 300 && lev <=860
        idz = lev == levels;
        zz = xx*0+lev;
        a = A(:,:,idz);
        s = surf(xx, yy, zz, a);
        shading flat
        c = plot3(clon, clat, clon*0+lev, 'k');
        k = plot3([70,128, 128, 70, 70], [20, 20, 55, 55, 20], zeros(5)+lev, 'k');

        print('-dpng', '-r200', [infile, '.',num2str(dt),'.',qstr,'_mt_',num2str(2000-ilev),'.png'])
        if length(find(lev == levs)) < 1
            delete(s)
            delete(c)
            delete(k)
        end 
    end
end

% }}}
end

figure('position', [515   157   570   814])
% {{{
hold on
for ilev = 1:length(levs)
    lev = levs(ilev);
    sl = slev(ilev);
    idz = lev == levels;
    zz = xx*0+sl;
    a = A(:,:,idz);
    surf(xx, yy, zz, a)
    shading flat
    plot3(clon, clat, clon*0+sl, 'k')
    plot3([70,128, 128, 70, 70], [20, 20, 55, 55, 20], zeros(5)+sl, 'k')
end
p = plot3(xq, yq, [0,0]+850-1, '-')
set(p, 'color', [1,0,1], 'linewidth', 2)

set(gca, 'zdir', 'reverse', 'xlim', [70,128], 'ylim', [20, 55], 'zlim', [300, 850], 'position', [0.17, 0.15, 0.8, 0.8]) % , 'zscal', 'log')

view(-22, 15)
h = colorbar('location', 'southoutside', 'position', [0.1,0.05, 0.8, 0.02]);
h.Label.String = ' ℃'
h.Label.HorizontalAlignment = 'left'
h.Label.Units = 'Normalized'
h.Label.Position = [1,0.5,0]
xlabel('Longitude')
ylabel('Latitude')
zlabel('Pressure')
colormap(jet2)
caxis([-20, -1])
if dt == 2
    caxis([-40, 20])
    colormap(jet)
end
print('-dpng', '-r400', [infile, '.',num2str(dt),'.',qstr,'.png'])
delete(p)
m = mesh(xm2, ym2, zm2, 'edgecolor', 'k', 'facecolor', 'none');
print('-dpng', '-r400', [infile, '.',num2str(dt),'.',qstr,'.mesh.png'])

x = linspace(xq(1),xq(2),200);
y = linspace(yq(1),yq(2),200);
z = levels;

[xx,zz] = meshgrid(x,z);
[yy,zz] = meshgrid(y,z);

[y1,x1,z1] = meshgrid(lat, lon, levels);
zr = interp3(y1,x1,z1,A,yy,xx,zz);

surf(xx,yy,zz,zr);
shading flat
m = mesh(xm2, ym2, zm2, 'edgecolor', 'k', 'facecolor', 'none');
print('-dpng', '-r400', [infile, '.',num2str(dt),'.',qstr,'.surf.flat.png'])
shading interp
m = mesh(xm2, ym2, zm2, 'edgecolor', 'k', 'facecolor', 'none');
print('-dpng', '-r400', [infile, '.',num2str(dt),'.',qstr,'.surf.interp.png'])
close all
% zr = smooth2d(zr,5);
% zr(zr < 0) = nan;



% }}}


figure('position',[200,50,800,600]);
% {{{
pcolor(xx,zz,zr);
colorbar;
colormap(jet2)
caxis([-20, -1])
if dt == 2
    caxis([-40, 20])
    colormap(jet)
end
xlabel('Longitude,Latitude')
ylabel('Pressure')
xt = get(gca, 'xtick')
xts = {}
for i = 1:length(xt)
    str = [num2str(xt(i)), ',' num2str((xt(i)-xq(1))/(xq(2)-xq(1))*(yq(2)-yq(1))+yq(1))];
    t1 = regexp(str, '(\.\d)', 'match')
    if length(t1) > 0
        xts{i} = regexprep(str, '(\.\d)\d+', t1{1})
    else 
        xts{i} = str
    end
end
set(gca, 'xticklabel', xts, 'ylim', [300, 850])
set(gca, 'ydir', 'reverse')
shading flat
print('-dpng', '-r400', [infile, '.slice.',num2str(dt),'.',qstr,'.flat.png'])
shading interp
print('-dpng', '-r400', [infile, '.slice.',num2str(dt),'.',qstr,'.interp.png'])
clear 
close all
% }}}
