ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.8.0
docker tag hyperledger/composer-playground:0.8.0 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.hfc-key-store
tar -cv * | docker exec -i composer tar x -C /home/composer/.hfc-key-store

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� -^SY �=Mo�Hv==��7�� 	�T�n���[I�����hYm�[��n�z(�$ѦH��$�/rrH�=$���\����X�c.�a��S��`��H�ԇ-�v˽�z@���WU�>ޫW�^U��r�b6-Ӂ!K��u�lj����0!��F�������6�r1�XAx��B��? ��-�W�x��r[s�ƛ�{
mh;�i��en��h�5:k�?&�5����>2�&\�ǒH�)�QX�kA[�jڑ^|`HT˴]���X^aV�5��2	�F[�M�	����g��T:J�s���Ώ �]� Z�5���I�0��Jl���^tC��U[S���0��p�y�@���[���}���,\Fܼl �A��6fFӹ�Ϲ͎F���]�&X��ل���5%�PBA�\kB�墔Q��5m�hT��7Cq`�	H���c*궥�E"~�0<���È��8�3�Hҋ���#�(�ɽ����j:V&�q�v�͖��<��.)o���(W�a�c#Yz}}�z#DXp�V��i:�Ni;и8&l�z�::JH.��8i�<�S�uU�� k�PE%k�>#Ou�����򕝲��P��A>�}5Y��ݎi���KO��3چ��DΠ�;�q������������ȝ��'�x��j��Л�� Dxl����sJ��G>���ʶjvo�
;�ۖA�����Y����Fy6�1X��Ǹ��7x�U�����4(�l�
���@Q�U��(D��by��)%�7��<���_����ȑn�h�G��($�0��1���W�g���,���1�o��	Z·�Ӹ�2��'v���ey���s\���'c�?����vt0����0
f�Q/tضuڠL��� ����<�� dC%�P3m�kCݴ��韎����^>���e���-H���0�!����k
4R#�q^�	���z�����(-&�5&]6������o��Z�@�YE�z���!E�ݸ8T�0�u�!�{�>��X؄��-��j�0���55�5s��jK�Րl+�MH��-�����X ��@�|�j����`LRx4�zI��5/����*/
���:�KÕ%�S��Ⴣk�������mU�	�� eo@��f����?�1�Z��bnCv����DX۰i�!
��n�f�/7���qM��3�E��'OU2�����3J��7X�,�H��j�4x�gi 	��	�-T�[FŎ�C�5���1Z��-y^	�N�3U�P��`�r�t���K����)�n�!�p��7�h[��8@v@�,�-桐6+\�cc��f��&諒�hS ��`MŸ����>AO�ǈm���x�$}��3�ϕ!�54�LC�F	���΍A��`rqlo�
�^���(�bKsI"L�j�Ϯ�@��P�rt�.�Pv p�t�� &�n�w���Og�)��k@�~�C��ۜƅ��(?��4w��������KD�����|Bp�v����z	@Ն��˗��C%���y9����������БJ5���?F3��Atg���>�X��������e_�Q��ś=C��.��OGJ]�_<��39����a5�b����vӶ\���m���@��iw�T��~qBU63�r��)TֿG�	���{_�+�+��'��˘$�(�Α��!&J��ѮT*g��g�*���  �-Á���;�&.���A�g�s	&X�t(�;��<Q�x)��d0
�W*���+b�rT�d��N�j�������Qg�γ�*�^gy�X'������0�շϟ�,D�W���dl��?Ol޾��Q,�$u�.�լB��}ͽ$*)`qZ�&*:ܠ~��A����E�oE�����Ѓ���x&�1�_A��Vq�g�mf���?��/����B���a��O�ݻ\ N��(������y���?���Z�c�j�@�� �lX��@oG�	�g��Թ5���!}��e���gⱅ��<`r��n1&�����[��������O��8?d��|la����Jxnhn;.��m�/�ek��o�6���:a
��C�}��'|cʶ�h�dW��=�#�mS8��:.l�5��R�3�Px�Bd0�n�v�Q����a���*�+Zs�av��C�@Q�]XL<����ut����\�W�Sh��!�~	���]�U�Y9�\��,���t�q�H�O��7w����(�s܂��*�χ�����i����2q@�܀ўsAO� �{���z�b�V�#!b�l���EM��zL�ڛ/����oO\�s�!��������߃ ����]�f����$���n�3�1���a�a�?˳��������a�-k�̇��V?H���o�-8��#:������ ��f�y���F ��3�ˬ{TR��[��5#	�"���o��� ��J�%
94G�Gj����4!vyp�U�����C7Yo���}��r^����c�U�7���B�ɻ�|V����4*�t��'knE�N�E����h�'0ɢH���P��̃sK�XCv@B��h�?�:BF��~D�w�����i˘���1���ę�B��|�d�|�͘{���p�G���XRq��]�W�k` ��[�pҬ�MH�ri7y��D�Oʉ�m)���y@�-�z��dGC��Z��DRC8�C�DB.�#8���tT��ґ�J��rYܩ�SREJV�A��,�I����*�-C;CR8Җ��2|>
;�O0�v>����G�Ү����;鑂3�u�"#���̑���	[�(ٰؕ�������N)S���+J��mTl�:���Y�*��ξ�,��[V���u�8�w��P�@�B
Xvt-��x� �T�w.�r��[M��g\���o��C���wS������0,�.��<�����ѳ��]Ar�@˺B/�i� �RA(D���������ޭa���*�W�P@_�x���\�c~�@,�6��ɢ7K�>�/��Q����V^@�����Q�;��/�?����m.��d�A?��?� �?�P�o��A
��C�W�N
3�"_�8�N�2�\H=��Fx��&��zF/�rG���ׁ�B�H��w\�r�Cp�����\
8Y����aq��\�Õ���1[z�5�=\U�ʓR)��(�hϞ̿>��-��V�$�������\
1��G�������� ���"Hn�jj���}"�n��u�����hZ��͡�I�x��'gP8����\���^��֋��A�1(Ŵ����� ��$�v�<�k����9�oF���c�[-���3�D���#3c�y罔��)`h��������U�}�|I�"��0�`��;"c�H��O2�=�!���{!�:]�/1�ޭ�굚��<ī����k�	�Pt��Z����d���_6]�������������?�,�>p����4M�84��L���\��?	��z��(MEa���M�8�f|A�54�h�w�;�b���u�,S�h|�á��;���x5�!���E(�h��
qV�P�V��\�BYX���
E�qLT�	��U���P���\��Ԕ*�rp��s{G����_�Z����4��O�0$�t&�R����$ŊDB�l&��:N&E5];��X�3�Ea��k�*����V��3�sq+Q��6N��b1%':٢�94����n���:�vwΥJ%�;R2��*r��w�V���_����"�K�es;�F+#t��=�X~�;��Kل�nd���+#[�u��p�����̵��K���9�%s�;��q�,{,vs��u�0���p�P-��W�zn7!�WD}��-e;�W��ԱR�{g�As�[m�li��!��M��V��b�C�d�jT�9K�r�li���N���4kUO�����nl��T�;�}n��n�t���桱edΏ��X����)����uQJ�r���I"wZU�t��y]���kǬ7�0�|�u���܍%%;�e�Nh%bl�a����g8�;;V� _>O&k���N��mA�iٴ�I��%�ph���HBD�[߫gY���b1��t2������DV�8�#%"�b2+����~��@�'��N��Ƶs{��)˂^8~�UW�ۛ�Wd��k�2i��I9o6�N�����@���XL�:b�$f�U�t�ܲ7Z��4c���Z�����/��VR�����V-�IfR|���)i�����Ŝ��o�ĥ�+�j���L<�>4H��֠/..�[N-��@8��t�4�ۚ����?����2�w7L_d�*���{�g z�m��ux��O���m��~��뾀������
 ���Z��8�ąRfM�`K�'���l&�)�%�?��i������H��;�f"�td�/��2��|Vr����ŎQ�Y�n��jn��U��WD����ɥ�+�FI�%E���������Y.�sI%Ԍb��H�vQ|���*�u=Sv�S�����ϕv۶*9�ʰ�+�����f^E�[r�zD�5�ъ�w�8�a������_���{��[����|�?7n�_�����'��I�� sSs�#�g���S\_N�Ô�w��p`f���g�ݳ)˘��q���s����ԯ>��Q{�=��G������_���������]�
��T�W`�QVa��ʰ��<����	�Z���Q�&+U��0U�QV`T�aee	P�m�K���|��������/����Ϳ������u������<�.]�/=�~"Z�����i,}����y��e˅���������i8��j��ҟ--Q_��#�e�����_}2���g��3P�%�#��,}��ǟ}�D�~���x��\�'K��E~��q%�/�����9LC�R��7[��������_�׿}�����ӓ�Е??;����~��l��A����7�`�lt����.���O;��en���R|"z�)�;#}�A�����ѣ���4I�{ѬG��D�f��1	�RiW*ᯜ�����.�I��=����A��2��C($�����L�{aմz�D�%HQg�`���vg�OF�6R�y���r���rP�0����(�ƪ�+�\5���rj�V��
r,�eN����z.pk��B�w���9x�Va��w-�앎=��|����g�JbG��'�Lj8�㉂Y\A��$�X��&RT�7QEI\D�ʡ!�"�P����rH� �Y� >: �� A��@� q� �C�܃ � >9���R�TKwu���zTW�������[��Í�m��u��j�W������-y�*mSϟ���
q�8��B��J+�ǱV"�IÆe���'��lEYa+����ק�?r'��EY`�B�y�H��5_,oY@�qO�q��S~�X+tÏ��q߉�߉&˱,2�����s%w����p�Fyq��u݁��tG��p:��=��� wܙ�9ڜ�3�9Y���[�'�?�	�R�7E�x�ΰ�]�[�]�k�8w�"�[ny~��z�-%���6n����������o�$|�o_��y�X�T�\��/lޒ��^��e�I�%Ϻ��%9��,���X���ŝa�����]��[��O�j%_�j�Rؾf�g��z�`�Y�k�:�W�$���{=?J:ȅ�x�In�QõZ��L/�;�x�׮�b�d��8�����	�B�ָ��0��xbV���IK#\�?�1�L���W���rhWX�Q�x!�G�f��UǷss�2\|���
��͐
I�2��N���~�Z�����ǣ|\̅����,l�낓�f'�����[��#��x��V`��gz�ɲi�EP{�h�]C;���t�A���C�W�B���������>�mF̢��R��L˃W��Vn��D�N�nJ2��T~x#�?9	\�bz?�������[���q���`�|�/���߭����W?~�/_�ۯ����|����������~������4�t����������̓��|���j+|-ɷ](����8��a�a訉岸	����δ�l�M�	�2x����#K�VA ����a�ݺ�g_�ׯ~�����m�7~������~���}#�C�g%�OJ�w ����ԏ�O���[�h��~���������}�|��o����[��{���_�$7HR�e��I?N��ڀ�$�9�Bh�}<Hw5�$ys��[�������
SvNJ�[G�������:Z���4���1Ca���Kq���O4�7�b�)ds��+,�������t�&�d��h�GX� [��BǨ�U��LP���ՑF��,:�̣" Iq�I�3�d8�$���D�.KN!�"I�]��#�?r�|��J�tjܐ�KN���ܞ	!W�fl?lv�Oΐ����&J�CBҌ�j%��6/�4?lK��V��@f��2�7�sj葭d�r�e=R�)��(�Q��D#1k&I�H�`)�d��c��./�.E�n�M��Y0R�r ���u4��=�籲�{�T�ݶw.1ݩI�ʓ.K���Fk�X�T�S�Qm�W\p^��\-���x%�`�"m�S�q��ŏH�UiK�Zd�f����)P~@��(B<ݤ�X6�O_�bUQz��$~����`��XA윕�X
BN�݅L�'2,x��v���FV���y�"Hl�D�\t���:S�b�!E|�f�6�nAr�
���c6	��9����tNo^��aƲ�4*Rh]ͣ�8;�F������l^�"�Z��X�=գ�U\O"/
��M��2}^������8��,�j�8 )�9�M2V�� ��H��M�g>û�b8 ��1J�$�[���K��:͕�$��|8A[C�כn�U�����ۄb�dCYJ�9�N���Ȱ�~���Rn�~�W�E�<Kİ�h���>#a��9]?��|K+�1�}`>�"��J�:w`Վh���A�U�	=���`j2*K4k�N��e�������pf}�2a!Ş����	l�f� ����W��s�gx/��(C2xs�J�<O�GVQ4�~�M���d�r_��BXfs�Yǂ��R%��U������R��]E�b�35�!M:�	�{�^��oR�ܴ��i!p�:�e<�M�x��� 7��nZ�ܴ��ip���K��\ ��+�o?\mE��ne�z�^J��:H���3�;|-ټ^��'g�'�R�3~q�{kꉇpz��=����x�<��o������o�[��K}�^�O���x����*�JJ�R�#�i�|
/�h'�{�:���]3����L�Ф��)M
/�]�>�0��Z���kٱbyPШe��֤P�"Ŗ'n$��ö2�J��XӜ	��+%^i�X�!"C�6�w�S�z�Ӗ��`n7L�J-V�F<����O�����M��,�RH���,E�6������6v�~��M6�#�S/��Au��#���l�&�`ͼL��!˄�ku3�@@x.J7K8��3V������dՄ:�m�R�-1;Q�W��R�n0�Q;{*��F�i�:#��6m6���Xo�"t�jGB��fD6 �G0 S�G
7���������������<U�ԅU&��d�(<���4kh�z����S������X�R��f�5b��?�6���/*L�����3�!0qSE��,�V��U�M%�n*�,T��\b!V�U�T��N�d���T,�*y
�lQ�� ��̺���1�?��=ט��N�~�����?�DG�}:��b�"����O> �Ӽ���|p��K�����y���3ǿ}%�T��Nw������PzR�]D(ʙpCq��g���)+n9�%1b���e��	� O+�6]G�i`eU��G��m��Ǿd����&FC!�X�+�.R�@.PT�oI2:rfd�3 :�	�tI���uq�^c-1z�`�z�<�$�k�B�T�2��T�=�f�E.�G��*��t�֜�&� Db�cǳ�E����QT����M���GE��Bl:,=w	Rx(�cC�;sr�P�b�-:��h�[�9�	�*"^'�Q���ѧNG0�G�z�F漄1r`�X�e��̲^id3e܅(m�%j���#h�$��^9��X�;=�EXTXz<(T���D+���c~����3&]/�֕�#�ϒ{i�$��@����m5K= 	�<a���� ���K��'	��Q�`��v����j�u)VZHg2K7�=��bd�_ҥ�h4�b��Aˏ�]���j�#�c��ڜ�(!?Y܄V���Q LY����`�����T���Ɋy/p8و��t��0��̦C���5(_�i���)j�;宦v|��j� �ꪙ�t*aI�|��V+�a��6��iO2��]*4�}�ݻJ�}��>�~�����G�v��h�g,Z��=��^��kWBp!�����iMZaC42	d��&�����>��Gy���3�����="aA�RmQ�B���,�R%�Rk4n�u;(z��'�]�x�H�rM"Lf�l5�zJ�ƀ��-�5f� �t>�՚G9[5��p��;Đ�,���H*�#)鑱@��k�+�<Y�c�E�����j�V���uG�>��^�Q+X4��Mш׆Hٮ����4�ΎJc�~�Ƀ�Wo��WU�R����B�$^@�+��8F����UT[�f�
�H��H���q�C��i��ԗ^J�E�H���[?�8�y������9�h�2����d�㑻hz�����Z�p*���z3�
�r������W�������J��z� x�O����'��.���GY6�N�|�瀟E0�+}��{�\5�:����s��x��x8�=_�|��e�T����{��,q��z'C�>�f��;��!{�3u��T�=;�_\\�i�۫��hb,j���;�IL_8a'�7W�C���
C+L�Z�xw[5_R����2��?/*=E�����k����g08���}t���,��r�'�Bd?��A�|�7ʦ�f�Q���t'��a�f�?h���6����e�殿瞶�m��S�?��{�����@�y�ǲ��o�n�/������i��{��9���&�g���c�_t�KZ��=�������s�ǐ�����۠������/웺����m��%���L����?���t+��p7�<�}�z�]���Cw�����3{��6h�����;�;����b�w�3���]����ۿ#��?�������ϷB�~ �.F��������~"������e��w�c�/yu�>�C���/��w'�[����۠;����q��Lw���`�������۠����+������T�����fܐ�P4£Ϩ��?s��(�طo,�y��2��ǧն9(Wg�$<���<�B���r	�S�*�@�Q�(�fr\���.��2�e��;�0�p��Q@��RC���lk��$�Q�3�Q��x4WG|0nv'C%������ �s�eӍ!�����A"]�q~�WxF�1��O;H�!*�)��(՛X!�u��`���D.�����'M�Z}�ׂ���͆�AӹZBAZе�e�Qv�Z�=�	�ް��,���n�vl�u�Y8�G���������������#�+�of�& K�	�33p�,�!
麭�3J0j۹6��z6�ӱn�m�$��Kz?�t���M�����Ak�M*���s�g�c��+�^'u�N3�AQ;����7z����A�.��X�@��F�����YeN�9�;��@D�5��<�2X�N*8�p��̒����wfM�jY~�W��-��� ����L�t0�8�������{�^�5u%�D��"�L*#���^�쳎o_��"�tS��m��,���ڝ���g��;5n�y}��C����Z��7������??�a���^����4q������&�B��I�)��n�F�Vu��)�������?����a��a�����{��/��4����(�9A���c2��y>O�,�R!�������N�<�%>bY1�h>���������� ��~e�_X�1Î�{�"Ѥ�"���6�h��_��Џz�V�u�O��=��Q����®˵{eB���.nh�Ă<,�*�d.�.����<�z�l'�B�]���A�%j�B�Zh���_E���^px�S�s�����Fx{��T%, `K��g��,���X�?���hF�!�W@�A�Q�?M�����и�C�7V4��?���r��k����o����o������B�����+���w����ӯ����w#4��O��������O���������J����?���/��O���M�MY����!�j�a�Z�c���ks��G�V������Z!�͵V��',/jb�{�����1�lr5iw�hٳ��T�e�0�\&�c���cG�gI1ܵ/���9�c)��u��Qخ�Y�Ok��p��tEk�h�%(�Sx��J�Ko�7��1�|w��GKo�cE	�n׺�,��g���m+�H=�N$n�l�6��#+4�H���������jw��E�J�����ʎ�`6Ի�7�����4Q:Vi'�iu���9���H)�x4�;;�s,�.T^-]{_�W .����
���~����{���~9� ��`���������������N�P�A�o���~Q��{�����;���!�OƎ�]z�Jڶ��攗�&�d��<�Թ��������d���?4d�ny�pg�5'6��c�?�Z�^����IN�i�';��������r�?��zVV������۩�Y����Nr+Ql�'�����pc.d�C��z����J�(�`���@�k��~>���hqI�#ϡ�������x�@E3��+0���?��EG��+@x�����t����������������O#����T=�)��	�����3����8�?M���d@���)�w�SO��X@�?�?r���g�@�� ��C0 b@�A���?�b���F�G�aeM�����q������������?�"��������?P�����G����������������CP���`Ā�����j��?46�����18��������F���>�j����Yo�uf���Cۣ�@9P�o���_��sS!?��^0Z'EW���'���qu��ړ4��qb�O����4~�v��2$"c4(za��b=5�5=:T������aW-�2������-g�v0Ɋ�P�->��������W���Kko~i��B��N��2�Vfǐ�F�x�ycV�r�RҦm
�����:���_j�~���4KeUϡTG_���K�BZ�D�&��)�0�sq(�A���	���`pX\� ��c���iK��씳�c6K�Q$O�C�}e�aQ�Q/���k���*�V��!�������A��W�������(r��#Q����Aq)-�"�%yLQɊ�$�<%�l�Ͳ+I�(0������{���3w����<��&���O�ww:�2����{wש|m�Y��:z�,k��ǆW,�����M I�`�v�bF
]1j�w��dl,�<�Ȳ�u�U�U7����jC����[�=.Ǆ�X�7��p��o�!�ޔAZD��ު����arN�ta�mXӻ�5�N�?-�ӛB��c���@GS�����?���?�?t`�����������G�����|�FP�����A����?����@���?��@���]�a�����L��?"���o����?�����A�������?,��?������ � o����g����7����Q<�?�����{�;{����ϸ�����́ݍ��7��q~�f��1Ώk���[���M&͢1�:�΢�k׏���fv�ѹɃ��p*���i����m���TC�R�6�5ެ��]���zZMMC���v��7�2�Gg�������L��T���g�\��}��u�����j�{ħ�JG����s�ZsYSO#'�>N�z^ׁ�3�3[�t�gj�:D�c;�A1�n�,뤽
<�ނ���
�-��عu:9�'��ps�����Z��R��{��g��]��MX��1���e����b����i{S�k�U��]
�c���<�-��ȯ�{*s����X��{����ɡ�g.Z9��f�GS���UR�Z�m�?����3�Sh��6]B:tC_w)�Y�.�R��K���UnJ��5)��y�שAޤK�=WN�b�ߪ��Y��B���������?������Ā�������E�%��S^��,K�f���"^��H�>Ix�&�4�cI�Ɍ�sV�h&O�$�R:� ����A�!��2��!�-?�*{N]�-��n><����)҈����<�[��S��5f�A�[]iw�V����Q{�Ug�Kp��~��N��S;чʭ��χr:��(��lg�������w�k��v	���[����x����!i��� ���z��������K`yW���?��i��	p���BGS��������@
�?�?r���/d ���B�?�?r��������ۃ����BH� ps4��?:��0���?:�+��e�����ʂ/Jv9P���.�g���"L��?5���w�s�t���Pr�~���;��������Y�Z�^���m�u��T��;6]�]wH�ej����x�o9�k�(Omm��-=H+���ej_�Pr�n�z�\�@���>���J�y�q"�a�ߏ�5U��>8�%���\���;}M�o��h}�wn:�9�X�9�Լ��*v,ce��{0��|��C�*���������B�!���?�~D���_�14��&����o��3Lo0]d������N�K"���O���E��}��A���;��]8�0�h-�jR��f^�n&�q����e����b�;�emne4=�ֵ&��DH�����W��-�t���R���N�����&n���k�7��T��mxɻ��1R���ՓUE��
����c�Dx�j��x�q�n�^��j�:Ln/���Ӽ?�
y���2�}-�:�땚Z��l�[�6���v�i[��]X�������!���������B6�����18����� ��	�������������a��L�e�G�ԩ�P�M����n*�go�'��N
��5�O|��w�|/��U/gF=v�/�d�R�],_�|�5�b�`΃a�/�	��ܦ �nN��q��^�hd�zzY��\M�diZ׭S��2�l�/<~ww7�=��q��Kko~i��B��N���ү���1���1�vy�8i�#iFF���7�T���t[5�S��{�x���=���\65�ӷ:tw"u|�ksim�m��=C�!�h�3��M����EZ��D�e,s"�5��s��>?�֭*��ݢԒ�DWvN�oc��,�?��B�����}�8�?����D���c9�J�T��!�"���Ld������GOg�0��sA�!����A�_�1p�W#����b�:�2Q]�GqXv�*\����`qv���n�5 ?���ݝZ���H7�50�^Om�f{�6��!H�6�Nw�pu.�}�k<�I�%����k��l��&���)�#c��%	�_���域�0��o��I�_���?��H�_`������7B#����Ҕ����7E��k����o����o�������?�gS�#�L�s)RQ�$�9)�".e��Ĝc��cy�.��L�<�3h�8��W�
��W����yS8���$���3j=�c�3ٖ+�n������\�d����u��S��ۻ��,F�}ϯ��%.���u�G�t#cM=�\�<�*�y%,�YWS���<[]�U-��j�w�����������	�_������JX ��&�����Y8�����_Qь�C�7��������~����q���o�hJ�4�����!��!����/��P�5B3��|�
���]���p�:��������5��r��� �a��a���?�����b�q�����p�8�M�?t �������������G��翢������MQ�O�5M�������F�A�i���?��M���x,�����S̳���M�X�ac0b@�A���?��������A4��?�����_#����������/����11���w�����0��
L��?"���o����?������6#�������8���?�#��*�����F��o����o��F��_���?6��o�]���G���]����b��#��\$�L�&q�g	��Y��"q�0�L�&I*�� H\�%�fB.�"+����������Գ������?�����������_��sM��J���u��X�\J��c�ں�T��;�"g��g4��灛�\P^��.�"����[���J�S�t��o>d$�TJ-'s~k�������1x�O�.{�4YN�45�lH���ǵ�j<�.�'�dr�3gS����2��S-���("��i���d4�,�#�r4�ь�7T}���}>��}�Ϧ�X7�rV�*�j��T�/x�Ї�?���m����_Q���;����_w�������1����������?:C���t�>������ ������? ��������l������'��G ��c�?������?�� ����?:��[����A�Gg��?� ��a���$u���x3���m��"O׵\�*/]����f���_����:��� �#��MƫG�Ѳ�W���t�Iw�^����$�Z	v)��4t�Ko�)3��<����|�����ڴ1k�_���z��a^���O֬F���hw8ۗ��$4\�ֆ=Z�XTmu��e.�2��l�jЂ�q������":��T6|ʮ�L;�s'7dˇ)���6��]�����c��?:��[����A�Gw��ѐ���S1J�1�`�p�xL�6��!�{X�����Cc?�zx����_C��t�ߙ��,
^q�[�s�'w�B0���)��.�+��9lWY:����?�����L�	��'&�Q-:�6�2B�Lw�ڂ?۳����v*b��F�	c1Ƽ�Si4�]k�N�5��x/���q����������q�6�'���>~A��x�[��~����������>�?������i-|�#�#r�0t@�C:b�D�!�c,����SW��`(��	$�h���A��D����?�h����3yY�⹞e	�m�t�٘�QoJ\�pj����19�|�4����zǬ�G��l���KK~	���I�"����2��$
u=U"b<?9~f�"ܒ�&%��E��RӁ�{/�p�G��_p�������_�u��a�}���翭��/M���_�&ܬ.�'7��Q1SL��Du7��f�{�k$���/��Y��1yi�����/�{�$���������-_ЫoM~��}nY[���K˚�����`��;�&��.;�㚷�M?A�"�
,o�;���Xg^F�X�g=����ư�M�u���Y���7����U6B�|���;q�aoMav�<���$���7�$��<�tj����<���dm���a�_CT@|���L!��Lg.fӄB���>�Y��f�+2Ts�Q&�m(,�p�Q��bG��x�+��0���$�|E&��ă���`�������?�@��_�������
��������?�����w����e8�������w�?4��Z�[�?���O0{��ck��V9�9<2X���}�����������~��}����8�<� �*�<�<!��aZ���Ys�
?.'YV�Q�5-�1\1� 
�Jd��9YN��NDs�"�y�+_f��ɸ�A�Ϩ����������1>��6cY�6x�"�F�U^f'��&]~��|�,g��Fa�"�z�8�e6���F6�h7{&|y��MH����O�<��"�S^�5�9��u�LeK���A�����j��,5WaDR�{���.�tM!+6f�Da?��=w��"��;o��}������
ڸ���������������w�6��8$�7�>����[���#��� �������������냃����PY楍�i�����s�.�W���y7�"o�Ll��vɷ��W���q���u��u^ܲ~�w����X`>�ұ���r�L�,�̆�l����w�L)�S�\�0��s���IM��&Q+���GkS-rL���Bu>�2�K�Ɨl���:7�˳:��c 3�s��H�u5�9��`҄Z2=fGD�r��쨜�~�7�~���WC�\񒟰Gi ���i8]�
F�w���ҕ�H#zNI[�I+�MEڛ���c~���S[��T_Sl��7cSg�L�hF�D��?z��
��v�N��~����������ko�L���7	��$��
�-Ur'�d�����w�m�����w�C+)���Ri4��B	���FF�$۱yT��ZIs�,n��_��#bt�����C	�ذ�fZ5�bY5yy�e��T��;��TJh9�b��2c��T�%��?�7�1�R�~�Ä��M���̇J2�������E
_��1T�I�0�lZ0"?�c��
�\��U�Ȍ��*w��ġ�($�sE�)O��]�2�@����@�w� ��`������_���?`�����@���C��_�6�V�7�n�����Q�j��i��b���t݊�?Y�_�rC[_���	�?Sf̧�76\#o�|�����Ds���<��12GжTL}�v�omT.ݢY�e'+�OP&�#ku�p���:0oy��Nb 3{G��qì��d���:��]�7F���v���8��f>��d�m�H���ȉ�;ֺ��;�wW}3#��Up�US�p(dϳ�hH��a��g$�9��
p��m����{��������~�@�߃�'� ��� �?��'���q�z����Gg��;G����x�C�M��wN1s�|:����(T���iL��ЭK�Zq��+Zvc�������),�Y�w��ي�F�pGI��ݟch��?w���ժVYRE{C����n��n3�;����o������
���e�WO�D��^1\V#Gi\,Q٪k}��8_�Ւ,�{��MQ� Ϥ�F�[ݵ;�a�D[��xϳ��_� |�>迫��_:B��*M@�cO�>����c�Gh��A�o����� �?���?��ө������������}ɮ�%��C����������O
� ���v��n��#����w��Bܟ�Ҁ��@W�v�����w�����OP�k	=�P�m��������� ��@���@����צ�;����?����c��@��t����w��?6���?������/����`&� ��c�^�?������@���8h�������������f��?Y��=�UNb��Vcev������~��/���iƍ8WB�~ν{��u��A�U�y�yB�3*ô8�sS!��<(~\N��.��kZ&,c�b�Ε���s��n흈�.<E��bW��b��qɃuN�B`/��\���e��'��'6cY���ě�*/��YY�.?�N��\���\��X��C�e��2��S]#�C��ݯ9XU����g[Dx�K��8G0�n2��l�ZB6>h�Qy�ryZ-ؔ��*�H�~�ԓ@��.�)d�ƌ�H"��s��:_��߿�^�?�A�+��m]�<:Wuq������l��������[A���L�0!�xc8AQ^�����"d�!I�^�Ga@�q4D� #�֐""�Pz����W���C���S�=������W�nL����$���/��V��Q�6'!�w;��DNa���H}��k����u��dNuP
m�R.�{3��{+_�y�&���U����48���o�q�N���%_NC��؂��nq�7[Tx��ٟ4W����I*�ω����=��_���������4�� �y{�6��_�(�_����=����V����?AT� �������?A��t�� �s ���9�w��`��%��Ah7h������V �?A�'������>8���VЩ�!P������z����������z���?a(��m �?��'��򟺭�?���[A���@u��?����w��@�SK�	�?x���^��+���ެ�_n�����.	.e��g�^l,��t�����Q����H_����l�M�������0ʯ��~yVyA��V=aE\ݞp��A6W�S���1%��&2����6F�ʚ0Gs6��PmK�t%!�}��E�旎��3�7m�N�RKU�m��ٲ�o��cu�M��֕ �j�S]W_J������\b��z���4��WG.�������j��->���#������#l5��p)��8��%�S��Y���^��'6e�̼�gPL@F�w�4ۚcb�	V�!q����U�| ��#�B�!4�����?�9�������������o+��G�Gġ�1�h8�H��bt�T�$�S��7]2����0P�b�I�!P��>�����������ߙ��C�<��`�ʊ8B�s�w�ω=UY����T�6g>�?-��?�7�2�T��"�I����{?�Cٞ���l9���q|���`��8��4�Mj'����z��[O]���3���^�����ԣ�G�Y���x����w�F��v�����t�^���|Oi���}��CU������tW�6�OWF�z���'TE����l1�dW��lf{���vg҈`Z��dM�]eW�l��*���#BC�^��]Uv�.۫��	���HK )�!+�eE�h���@ �$��|�!��V

Uv�������>����.�{�[�ι��sν��&a��PnGF-���C-�T͡�z}�ww���E��A�-����%�����ȑ�����N�#;��7#��WA�`�䥠��wV� �Q��pw� ��G�ƹ3��"���o��؍��s�r@�F�3W�4�І��HDFNd!!�i+rн�/��E��fG�c�6m#ғGA�}:�z����Ѧ�3E�8��{��s�=���Q���=y�����𷀦t���/���2�z��Z��j����#۶�ۣK0M	^id��p��*Ms�J/�|�@�4<\����J9[�Uq!7���X�:���:�	zY� w"���w��/��Q�c�u"'�M��xdW��g����=6���2��VhwFӀEǴOD�R��t��O(+|���)�{��CY�,�����N�1��vj�'���p�G���X0�Éxbc��+ ^� ^�����>�ǟ���\Z��/�iMAU]EQEKƕ��B��VUI�XBA�����pB�e���J��ŕ��P04���P<�q��g���B����k?��_:��o����������7�*�G�e�u{��XO@��e�T VH C�{_�ŗ�@U���#�<�q�E���p�n����w9�:w��Cw��R�Aנ�[ ����������pz�T^Z�u�&����
^���,�v��l�[?�����/�����ko����w����W�Ka�\������x�#�	�ٚgz�	�1�؃�A�p���W�W �lG.�x��>��OD_���'���_����;���{ot�O5կ��D�}�!���ֹk点��_	��#��kڦ��h�J0c(J;����º��夬��	Xmc�t�'���&2�n��tBK"HV�v �7D��_��W�+��g��������+ri�����=�� �� }��| ,��M�G7O���	}�������'����{z�Y��=���Ň���0^���U�q�$���Q�S�>6�v�ʱ8�B=�8xN��qp:������H����' ���Rf�/S�+|��zXf-��U�E���y>����h�(�sZ`z��E,SC��\oM�>�6����#Oٲ�dǠ@�f�:jɍ�՞�-�P��;l-xv��ѣ��+|����H�o�_�/�h"	Ah�y�/	%ը�\*������<c�\5>��^���0�I�pߚ�F麐�!���R���ΰ<ɸ27�d��O�8O��Z���"M[x�0��G6�W�7�N��w��.;4j&A�fIN��l0��� �Ѳޚ�+iU�Lc�R;��f��b�����0|_.���M�KM���� �qj�}BF��͋�)%
��QV�I�d���I̠�q���Z��6}M6���'�3 J"]{@�z�ɇH���c�R��Q��s�c���|��䤞�]�4��a�
���-�_�`.�p����%�'1����L��:1E�Rb�"�y�t���Au<^�d�J�="3�b����+�hʍ&jDB��	c�����z�q/���tV�"�T�e\#-�"�7��gRX�2�ׂG\D��fk�q���V5V�c(S�/���V��Dz���&K��Q�C�{�-�����E���s�Xv��f���cì7N�\�i7�F��˦�X�/�M9�|��uܝj��Dѹ~���v�T'�z/��pĢ�T:�6�i��3����,SN��d�5��f	(C��Y
)w�W��,�>�h�j���%bL��2lOUJ�Ӎ���3D��t�jc9Fl�3��̣1^뱒��19��Wu��,��$��{�c�r��̒&q
kL6ϒ�D+�v]v2��N���\��t��vpx�,����A�ML�"L�J�L�b�֒��^A�B�3Ut�č1�Ϋ�׌�[����ZA�a��d��6���;�#3f��B=~E�9��(�Gz�6o
֓��NXObc����gش�ϰ	h�LO�cG���بq�og�Dy�V{9��|��O���hيFE�	�R���c�����]Ja�8o�u۳D�M�*��$uS��R�ɇ����D�G�c�l��L�uo0�5�U��N�'�FZv�s�#�	*w���wV��Od�|����Ѧ��c���۪�H�B*��zY8�w�4�4{e�v�q�@��ZՍ�&�Ĩ�2�yfje'�)VZ�Ԥ5������B\O�y�.��Ql{o)�?X���K���:�]>�o=�}9\��ǫ�ja|�� �Ck��-����M���g���J���k��_���������W�/\9�|���͏�D"_:��O�>t��$�b�n�ǐ�oƻy���4)�4�����&/�X�K�[-�M�����Y�A���0��r^��t��~m8wea�+&�Z�i�A�/�>��zq�w�x'r�$V�vTӛ=�������b˂���9ճS�+'2���{>0��p�j�8e��As��<��K͑��Sy�l�ޠ;:b^����(��]�Q7U�N�Y%��<�ԺI`���"s���cV��e��>�UYO�әb�,R};.U�1����=5U��*6V�+�!�i<B�F�n�t���5���c�9aK@h:U�xj#��D�>r�
�!�����T�8-�������;�b�.,Q�~̶���%`�sUnVofD?kQR�mL�F*f=y��%|MJ��i��&�R/�~�&PIg��n"���F��a�@�4����ʽ)爪��l���E:NK&IT���&����T,�*y*9A�n��������]uz�2����޺ m��hÕ���h��"&�y��m ������no��Rk�~��-�k���S�������'N��|���%�Ϝ�@I�Z��/��m5�=:M��V_�@��^��;���$X�ǀ�'�"Y�R�v)�[Hg<��cyr�gDI�sN���kJ}T��af�r|���8e*���X4��s)���oBJrw<�)�0�a�X�Ow<mʱ�1���I�����{~��o�	���w�Նϖ{�VҴ�g�R�)u�[U���Jrt�3�^�9:�,K��AQfXuc���S1��@���9����&α�sl�?�q���꽟�7ު�1o�&z���=z���N��_�������^���LxoC�:m�y�BO�{����?��Y�@��f�����=�&�y���,v$B[��ۿ
��9���=a�j�5�"x�sz��A��%B)ޜkг��-p�����7�ߏ�u��G0��3A� =>�����W��s@��G���q��s�H6��>9n�F^� �!��]I��2����V��	�z�c��3� �Ӈ���{��o�-��䑼׀��"�8���Oxf�������C��4z�7Nۻ�؉q¯���X�m`��6��l`��6���'� � 