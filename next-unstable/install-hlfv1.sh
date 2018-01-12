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
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.17.1
docker tag hyperledger/composer-playground:0.17.1 hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

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
� ��XZ �<KlIv���Ճ$Nf�1�@��36?����h��G-�")J��x5��"�R�����׋�6�`� �� 9g����!�CA�S�"�$�5����&EY�-���lU�z�ի��O�b�؊�F�4l15iرWW�Þ����8�t:I~!��%�'�����Si>	�|ZȤ�A�s����ڎd!�cI��}2�i���r�-[5��&\�8[�����!�鄕�g��H���=]���J՞ԁ���Ė���b���JQPӰ��D(��-Ǘ�9��5N�N߰h��ے�9l�6�6���˽iY~K[jY�Q�a�L>hC��iπA�d�P|�H=��S�wP��9�Q�r��1�D �*����s�A�?u��'x2�<�H	D���$�������q��걖dw9�p-���u$+�GQ-�k��i^�Z����nJ�⏟�э0�z�}�b{�!)�}��b���H�E��!U�	�4��n��>b�AV�����M-3�����}]Դ"�_��b����B<��@�(�y~n�R���-"b����I!r���T�FIW��{�!�J�,W�U�3N
m��d;�y����j���u��2myr�S�������

��������
o =��8��t�]>C1Pؘ�jI�'�̵U .L��ԅ�7� G��B��!�Eڄ�3"�U_�FPj4K��d�>���Ym̴�ɤ�Ng��{�*�8�0C�jXt���cG���u�p�>�Z����
TG
^Nޜa�!�ߘ� C׆T �z���I�`a��oEC�2��.����N�wŀǡ�A1���X	�4,��Xò��]U�"ä��
s��^�N�]ET�8�I��'�0!��y��:�32m�Gw ��&؊��\�0޺�i7�9�F�ea����1�e������5�����-ɜb�x>��2#����ܖ ���� L��X ���E��������E����9�8���d"A�x!�H�<���g2s�����">Ěa����̖-�tPR����,C�%9$�k��b9�kY8H~kȽ�F@s����Uh�k͕��5a�[<����5�������g�K4W�A��*����N��Uެ�<g�^�;�T����[���n��j�C>��q�&;���f���d�����-M6�d�r�߭��h�5˕��v�d�'�f�Χ�u�d)��cC��§�HZh�k?x�d�\�F*���ѣGhi&��%�Ǐ��"��剬�P2q	�n���0��p�f��'}�LN�@' <���D��cm���j �I-�<~�N��d3��)�����ۆ~.4��_���?��� �?��0�����3��P��Ʌ�{�P��2�o�v�ģ�(ϳj3��ֱ�m1C#JOf�C>��E���m��E6<¦�J�ͱ\L�,�*	/P��:��X��bU������v.���ۊ�F/6��1͎����%$�Nװ��mp0�4U��t	�f��!gMx�7,ņ�G�� ��-͐䮤���\�W@yL1y�k<ܖ�jJD��z�m:pW3Q$B~ڪ�Q�ik�T���.b�
�epH���h6ʏ�!��Αʚ�h�ݨ	��k�N���@h!��go�G�f������������(����]f���y�����S����/�����.3�_�0��5�-Q�z��Wsg�X���_&M����1en�ow9��Gݚe�%�x���_Hg�쟏���.�����[t����,��Lu"��
6-,C��ږ�C��(����nc��ov,Bs's^e��Om��:���������QN�z�ſ��������|FH&z�3����E�3��+�p�����t��>�"�D�����/�L��-�cXCGmղ�-˰n!�Ruǻ��I�bG9r��mK|�z�-�3��聶�PtJsУ��~�C!:�8|��&�*�UD ��m��C����@X�Z�M0��&������K�gj3ؚ eg��8�&Y6���Kp�l��.I`��E�8(N���[X`:yr�saa!�bͼA�K�j����
9Ƣ5����E822RQXX�٫lK��ͅ���n�^�<�,Z�����G@޶���]�
1Bt����b;��*=_"O��9�QX_�ܥ�`���k���;5��.n6J����Ҋ�?:ԋ)�ﶂ��K��e��M{�PI,���$���)c��69Gy�.�	Z@ܗ�o��WLթ�mf�6�t����ϖo�� �]�ܫ �j�E(���ynlc� $;��y�Mw>�m�a2ht�;v�0G����Ƞ@��f]Iױ�y��� �Ȅ�A<jX>��e�#^Z=���(b��%
,R��L<G��t�f&�y�Xo�g0>6���΀0{�P��X���qq��Fi�V5�l�
����ZMl��c�g�1XA��+�;Ӕ@�L��'�FZ�C��C��E����*{��M5���#z�-�W�����t |K˙�W�~��ϸ����?�M��(���-�-x"���r���'	���zo9R��'Qn�KI��({)���&�t���瘣a:�G�h���z���i�d�z�X?|��^{)��+w��̮oZ�協3�?/~qg����l��.��������P:�������q��/��w��dJ���\H�%�a-��uP9_��,3�D�Rg��z�D�E�k��{��k��@HW�*#4��
p\$�ϹP�yH�_TT�mLs���%��vMg��4D-X�ҵ��� LVcPe�X&�+�d#S� q�[ƣ����L^�64B���午}t	�7�7Y�_�:�U��Iy�����O?͡O��"��=�iu$]=����D�Ө7 ���5,Gu{S]F<���<��O��O��V��L�f���D��T�R�!�@�K�}]J��� r�|�:��җ^���VA%؋������Tj���m�m���i轅i'��m�z@�=��U�3�38�Am��$U�jȵɎaͦ ��(Be�]���c�YdP���J�_q��Z�3��ع��ȶ٢2���h�L�lί�0�E��O�]�ap<��W�l��1=� >�M[Y�%� L��"A��<�}���g���E��B�b%R��>
 
��?��E��|�4�A`���74�{�OdBw|d�04#b���XbS[XA���ALmb��:C:k�=A�	�-�,WeՔ�j��R��Kn<�����6�Ŀ��Dv��Y�-x�����ó���:��)�.w�������Y�泉TM��8��͏1�d˰�WK:��I�-\����>���o��CIs�m����Q��Mx�EbD�GG����{hbx�L`��u�vr'l�N�Ķ��S�1�
��f����*)�1���Y�,A~���fX٤���e� i���8�z=цeJ�#�C�(�j��`�Mj��F%3C�T}Ǉ�x�z(�=x$o�A<�����e��T�@jHa
�`�-*��m,!r��Ĉݼ��7�6\��+��Dp:P���0Hۻ=E?f�Z�/�C��H{��z�I�E_�f����L�D�Qˠ*�N|��DD����j`�1ߓj���" hMl�`(`gA�s�6R[�%:L����jT�n�@�N�On�V�_�-U�`Xʘ�1cѱ��H e�pvU�A�j4�� �{��p��!qT���='s�#��@ߣH�F0V�&�o�۬�X�`�I���$�A�$�����aM��^S�bT�ip�
H�e����6F�Z��u�3���hM�i^�D�K��l<+�=E j�R����G��x�4oA�$&��x����6d꣜�����7&3�sw�Sa �.&H��y1� �BDWg�_�d�z�	�������;v�}
�S����2���_*����]H���]n�{|��+�]��?��Ͽ�թ� ����V\N&��r[�e>��ڭvR^�f��VVH
	'y�L'��l")K�l*��[���ZN�B�.��w�i�!1����;q���/��L�+K7��	}�u.t|���__
���$�/.]�4�s��Չ�^�W.+č��.�=�w����?��_��"���{ ƫ�|�����7=󬼂�{>��y�S������������)\�
J�}���_f��G���W�e�M�����k�����W����~��_�[�y�K��=�r�._��%�?���}r�N/���'w���rB�R\J&�L:��d<�̴����T:�ߑJ�Y!�S�
/�����<��]	}�������o���K?��/�ͯR?����Ĺ�C���G�������~��G�,�_���C����W���[��Z��?}�A�_>��m����)��Z��
�F��Z.����*�r��_(������)׋w[����훎v7��S��v?_7�Γ���f�^/����J��s��nq�^_+���l�� $�ۥB��QVm���C��2w����|����궰�K����Ծ����:*=��eֹ[��w��VJ�k���6������fI��
#*�]��r�E�ڏ�G�P��T����C	ꆬ���q��ʠp$��w�;yq�)j;�J��/���K}��{`>�e���֭4v��"m[/��&!�i�w��^Ք��a�q�_�S��� ��z;���|�����
Y�����:�ȕ��ݭ�l�Ճ~����a<,��b}��=ź\�w�wP��n��|p`�,m��{ʽ'�ؽ�]z�r��'����9�ny�hj��qu�n�~c��A����V��'�C���N`�+Uە�x�H�l�kb}=�a�;k���LfA�򩈻k\~��!��}
�d��}�_�ǎD�w��,�;�Κ�hO2v��.8%�)>�����wS���L����]���5�$���?�hh�(b�SZ�1m{���J�N���e-utS����nv�d�V�����=�S(�=���TZ:����4�5}Y<4[����9�6�&n��z���co�8j�j񸹄��TkZ#�$F���S�9Tb���� ���>=��|T��U�f!�Jag�2(����f��m�i=�wW�_��۬Mnw�Mͯqro�F;��kM�0�����QKϣ�h���Ύ�]�n'�LFʇ�����J�/�6ܬlc�6��\�.R��\�:��Q�@�I��
�)�����mO�yZꢌ]`�y����Dz���~w8��l�׉����*�X��(���C�>��ĸ:tT�pbu$��!�CB�����|<�#�N��� ��<���;}���ld�s�g���*"�[���ӌ/�w�8�,1��.׶����n(�y}C�ݠW3GDD�C�l2[���f����^Ϫ1��5Ѓ�P�>�_�|Y�))T��ǅ��ǵ�a�u��E(�|�ŏ��m�>�(W����W��(\xՃ�X+\����o�)Vbihժ���t���#Y��
�*��2Q�-k�0��m��c`�Q�6'i�4�i=/[{�0��p�/R�D���l�z�J���D��OUy7�W����X���u;J�i����ij3P�-�t�k��ʠ�/��	R��G;��'a�x
;¦k -��RU����v�a�$��~��9�{(�=�z��R�=;�@I�y^�)���@I��}خ>/�@���z�&���-���ؖE��>�bQ@�M��v�ME��f��JWf�%�D╶��[�d@7�+�/���x�����]�՟3^�ch� �-��}����ڰ��>Fj �16Ԗ�[�O��np��@k�B�.2�	��!���ʬg�t�#�H.#Ę��n�b6�D��QW�N@�����iB��-o�y�tS&����d�J'�����<X��
�
_~~��׿H�ۍ�;] �:��_q�O������f��U����6��+�}᫃�|u|ﯿ+ݜW��I(����=��_��Pxux/_>?��/���o�%���P៿+��!�v���߿~�7��߿-�뷅���|r�?����@e�6�KQy�0m��N�V�x�E̷��+<�c>����N\�&^����_1�լ�瑹���s悮�K������.w�}d�FB��
J$�i0�;7�Bbo�²��1���^��=R�Rk�#�"�h����d77�=E����^�L�f?��ᦶ�1��}�	˞��N+�H�3G�1�5��5˔�b�UX�zGF��3f���<fx�y�X�IȴZR�������X��ӀeJ~��=��u�Y�|y`���U���d��x�Ԡ�J_�2<+0t�ݸ�m����n�����AA�0a��p:n�t!�b7&8�x)ٙ;�'n����Mi$�%GR&zi�����!=��?=�i�D(�'����$�����ׅr���ak�<��V:���]�\�3��@����S�b�.o���v�Hة�x�N�c��1�t,���C�����]i�ӻy{�W��d��O�й����~4����4��oM��&�Cc�v��6��Z/�f������yb[u7�ǭi�F�j�IMfV�Ѹ�WR�-UU�{B��(L|-��k��)׮;ˈ�X�3�9�*��ך��W�ۍ?��E�.kO�8>������9QV.B�~��-M2���9�r��W��c�=X�Nmd��<)�Z˾"T���q�0>o�e�*zc�H�x�lG�N��#0jp1/�{�契���>�I ��E�L�ŬPk���`haʅ*�m>�@2�E�&�l+G�8��;���U0��;s&Э~0�X;v&�D�
t�y(�<ôvǩq�bHN�� 5��Ĝ
�J��B�B�3��钏
���@�	C�=�D�QQ�I�=�El�/�7T�WIDyn@��垀B��=c�Ym9�ǖ���Y���TՈ��E�����T�;�{
(,:�z�E|\&4{�F�A�d�����&��B�%\d���%���m^[S;VXri{�/�x|�3�}Ǥ�?iu��.�nu�?~Ѐ��t�ׅ�Υ��"���~v+��|�I�5��m�a�
�&��«㉯��e2����u�,�)|S��"YDs:��/NKN
�)���͏?������?��{��5/��_@���3;���M�0:�$\�!��,�g���:}N}S��d�*f��h8M�=tC���������Ⱥ�@�V���{���t�}s�8��H����ۖ!�Ջd򩼂>���>x���O��>�5���u��C���J����������#��W*�(������?����S��қҟ��_f.�x����j�;?�d����B�#L��W�#��������<z�Ǟ������Z5Y�&�[�F�?���d�'����
���$��O)��u��;� { ���=�����*Ȍ��:�Y�< �����?
�����4�)�;��>�# ������?F�񟌐�w���&H�Y�9ɐ����?P��I������ �m�����.iY���\�?��8�i S��� d
��_�������� 㿩 '��<H���0r��	� � �Eg�g�3F.��\��4����&!X�-����/��c�������W�*�ԑ�w������O�����m=��V�=�� ���̐�������g	��_���������`@6ȅ��������0��r��S@�e�L���݅�|�������/��!��A�ߔ��wHA\�.S�rh�ȁ�Ѩ�;�5�2�T�E�t<Ϧ��3���3H�$�~��<�?F^�������%u�����;������f���V26�i>I�.��0��w׃V���Ƣ�R�ţ[[t�h7n�b��jC�yEwr�]D��]K}��6p�3�T��8�)�-Kf�	a+���+BD"3V�ϰ�l�\0~��vR�a�c�_���߻���?�!�������h&}s�<����C��������+�9���?��<�?���C�?��T\WZM�,uY��Z1�weƪ�Oz�ZG�����G�W:��@m����-xY�N��1%��:�F��L�re�\SjsJ˚��[!F�H�#ٜYt,��R��}����T�"��8�����z�>�O��\���_����/������Y�� �r���B�0�i����W��q����*�П[-��	D��)�������o�g+l_D��������6�|���%�U�-S#`�h��h�V��iٝAÞu�T�E�f���fqI��7�����>H��Н6k��B���,0K��|9�mWMB��l�]*~�ή��'MY��<3��rz[�n&��B���*M!֮&��3WZиN"���[A�+��3��D�w.��3�'4_�	a�{5X�f��NE�x4jz5t��)�c���l{�H� �R��0^1����@W�m���මޒd�pD�jT��R?y�w�<�?�g�������k��F�?6�߷��?�@.�����A��T�
��"�����Y�?
߳�+�?�����k������`�7��_���`�W��k������
��K	��?��Kn����y����
��������/���߳��@��O`�?X��������������%� ��e�<�?���!m�������������
��/`�����E�B�����G��7' �O���������
r�����_X��
�����s� &d�������g������P"k ���9����̐=��̐,�����_��������?H�i�������O� � �@�P�![�O�/��RA��/|������/�O�����'���0��O�
�L���O�?������VF���rGV}C�?)�_�?���c�?��P7δ5q���1M���SHy.+�f����ke���I�e��Z4tE�z*:���a	��ͼ��;���
��P���bd�Xr�3�%��!ߞ%I �%I 倴b&n�Y����`4Db6|4]����`IuB�8���f�n`��8�%Bz��z[�F.�ƒ�#�4�CԵI�h{]DSc{8{1v�����ܳ���H��?P2K ����_.��������r���8d�ȅ����#�* �A�GP����l�(�%����/��f���␩#���gP���_.r��迌�����0��\��� ��/[���1��#��O9���)��(�#-Ǣ˖;�`��&q!PE�2����{�6E�t�B$���c}�?a��1������tp���-�s�E�ׄ����U��UDv�u���w�8���V26�i�A�)=�ge���/�=�ὁ�2����o5do\q{]��d���w�.Z�m���XY�*��ž�Z���Ǆ>fY�f3��}9@��}�)G�V��Z��]��V9��]iQ���]�T�xΐ���f�l�4���"������?2C����o60���%"��_v���oa�'�pT���̖0ėƸe�Xu������Z��`� ҖG�G�܎X��%�X,x�V_��I���z�$�E�Ӆх�eWQ�4ة�����5D��g�*5'�p��Ɠ��ng8
��S���Q�����@��߱�8�O��Y �@�Wf �_ ����/0��_��?@f�<�?�������?3�>w���CgA��M�+�ExdF�%<�X����75 ?��{^@�p�P��ښd��,��Ԣ({q���ڲ���vh9�'�0g�/Sю$���N��\��ޞ��5g�v)����NF;��T�A��c-&�j7:���W��XVkW�8EFkW��g�ܚE�0|�_�j�|��UTQ�8{FEE��[c��'qO'���Y�TMu�t��e��[�Ҕ_��5$�L^����56<���n��]�'���Ծ�,�Z^b��'ے|�S�s�K��ǝe4c�HOt����Ƌ؋�I�PY���k�F27R/��z�vHW</3�l�N��z�;v�-3��("aߝ�G�;*ƈ�LCC�A�Nh��&��?]������_g��u��	�A������?���/������X��������/���_ ����?�%,�8��$y;���.I�0d"��~$�1O0d@���(h��<�����A���_Y�����F%��ک�`'A�$K�q��b���^���+G��[���[nQ�Ѱ���J�����?�q��G�����Lwh�+(�����$�A�I�U�/�S��(@��\x��APAȥ<A���R\_��HHq��I6M#���4�����OB�<"b���D��Q��	�����,5���p��ǻ�(�o��!�B���iLN})���^�+�X��}�\�V����������U����٫��z�������������/�����_�T�7�K��=ޟ���GC����绌�K���?E������+����@���Pܾj�?(�����00�	u�0�	��#���w���J���^����$T���0U�_������UF�?
�뿫~/�"������?�*����:�����P&�ɠ�����H����0$���g�_��,����k�ꄽ)ϻ���#h	S��Rj��̙KsP��|/�R��3r/�c^�ѭ�I�Lc@����ъ�L�3���V�dZ.�>��&3��<�(�)E�O������!�*2����ʹPa�/|{fj��a0��~s�[���[�I�������fEb�驖��/�E>��-$�N��X�bt��*�n��n�P|f_:�ɦ0��ޚ�nk�,��^l�:����^�m�8$��1Qm��^�L+5�x�ʞj����.I�Ue�+S�J�:���'*&�o��Ŝ��n)�D^�ͽ��V�l���~��
%�Ƚrp�m�]a~�)�9��8?w'�E:�l�U�-��%mQ���n�\��4	���c'�_2�Ƭ벻F���"�Z���=d�����˰���{[T׼x܄��;�;C�$��R����VV�����o��CB�b��!P���v�W�g������P/�|$>�:��d_�?��D����z�����Co=��)��|��re�����.���Ku��s���
g���A�!����ܯ1���Xw���R�F��D�5�I��񞣓�����k��k�7��[.㣩�9��C*#5%���(K�j���ǈ�3���]���뢤x�$uq:�(�9k<�ޜٳ�)��NG��݅7▶�NC4�A<����9S�xk���m֧������q��)�*�Ԯu��p��Z��g��sQ4o�����`aʆ�K��8I�lgw���nV�$҃^o��m֜�F���`���멩�DSqe} Ӆ1`1Yɶ�3Ih>��'4�k���t&�=�	G9nfz6d6_Y�s��se(zi
�a��G����Y��[�-���]o���/ ���C��4  � ��k����A��"�f��	 d���3���������a�v���~���a��B����K[^�_�������i�O�w��݊ �I �4F�|� {���5 ���E�>���i��: �`<M/}���m����Dv>aQ��{����c[�O#q�i�;�l��3Og�о].c�?�d�)� e��� ��B���p~.�Yh<�W���q�,������$".�ْ����}��ڑzvP��+�ɘ�WHn�l�'^&�������uq���ckii2QԞ1�����vQ����4�WG�])�K����ʨC��>����������2j��P ��:�8��8���8��W[�D-�?�A�'	�
��-�s��w	������_��"����Z�?A\��O86L��)�Oy!I#:�#�&��"��<�h<
�����@h��`Kܻ���?����r���e�+��)�!��=q��qb��ry\�[It����<|��f�r1p-{c��K;���eD��e���G�<��3�^&�;�Hu��So�����	Db���ݖ���*��inʰ�������?�����~	��UR��?��ꨅ����ʨ��߿�WX�����������_���e2�ƾ�����`�F7Mdmޏ/�z��6�?���FY����,���pi]�t�ᐻ�T�g�Ck���8f6��%'��ַMwr��^���I������(r�LJ�2�Ck����
c��{+�x�S����:<����h�;����P��_��_���_�����*��@X���p�a����g�_�i���=��:���=yǮ��A1?�R6����_�����=���v-ɗ|�؄��q ���Ԧ��'j6Zǅ�e�6ل�4�­7ӵ"��q$�n汸]Оٙ1g����)UX�y���}��X���%�:��o��m��ӭ�o���-��t����2�-]�t�\4��6��@ԚY�O,�8�Z!O\��N"]V���5�Q�^aѮQ�n�DSȺƝBw+���$��8�f|���q��Nݓ���v�!�$����A�q�X�� �y���L#9l�E3]on;����+P���� ��_E x�Ê�������P�AC�j���+���?D ���ZS@�A�����A�+���pך�J�߻�����H����������j����O8�G��V����_;�����$	��^�a�K����P�OC�?����������C�����x�)���v�W��_��V�ԉ:��G�_h������_`�˿���#���������( �_[P�����kH�u�0���G�����J��[�O��$@�?��C�?��W�1��`�+"����,�a��<��AL�	���B��<�'TƷq�E�1/$4�$��ﳨ�������O$���~/<,.��e&���3��H�O-����vD_Xˤ��|��0�[�x�)��px��f��U?l5��(ml����f�*w�N*�Ao�G,.��R򕔵�麤��v�@�mg�éU�?��:<��G���(@��OpPOP�����i��(����ă��p��d�m����{���A��A���A�_����*Y���Bp��i��x��1q���0��(��H�x"JX�S*��
9�OB<N�"8������!�C�����ic<[�g�|�6�k��t��LO�Y�У��"�FG�y�����fs˦�+.U�ɑY�TBv�K��s��xw6'&i`{*�LN�B6v��d��F�n�����q���t�\� ��V�����u ���%��_SP����)�����O���4�?
��������?<*���z�����/H�Z�a9d�����W����������:@�A�+��U��u��E*���G����� �`�����?����P����e��"������ϰ���?"�^���"H|u����?00�	?���\��g��s"�c9ً)K�`9�n�����]�j������Y���l����c?�����n��2	ɓ./�奙m��`k��!FL�w�.�au#�+�h�tW���$����[�cS�7�v�����f-�T�'{����'�)�O�^�MQ,����K��s�/6{��o������T4��]H̠�9�;�\'�<YO�s��$������*>gb�9Qly8MZ�F���ɾ0j�%�*b]��>#�#s��&��������^x����:�?,����r�����_-��y�����H���Ô(����?��D���Q �`����O��!��*��a9x�oǗ��׎�j����+�f�/�~�_��Ȩ������������?����-Z��zd5�qSR������b9x����t1S\�=�ԔG#�\D�n�3G^X�P]����xʩ=���"�5�~l&�X�j_���2!���������ٿ(<��c����<$����5�����^Xj��2����:i::�stһ�6z~��Rx�e|4��=�2~He���(Ko����c��Y
���n���뢤x�$uq:�(�9k<�ޜٳ�)��NG��݅7▶�NC4�A<����9S�xk���m֧������q��)�*v���Y���jYK4���mJb�+�\M�x��z9X��!��j�N�%���Ei����0������r�5gd��� 8�b��Ǻ�:Y�3�T\Y�taXLV�m�L�.�	���op-�I�k�-G�Q������WV���\��^�wb㑩�|v�i�;Ɩk�p������?"���"9�|���G�����A�)���G��H����iHpQ�q��D��LH��B��	�!E|Q,�\DRa�S1�@�x�Î�wS�8��?~��������i&��f�i�X��qwN��(4�c����x����m�������H���'�nG�s�W`o'�D�e�۽�˶b[R$9�{�y �hS��ò�����@��a�I|쎐�
�BU�
G�=��Ն���^��lZ����0�yxrn]}�i��Vs822��m�{PӪճ�V�5e��'�����:U����7M�a����|����o7}�2=����=]z�����s����8��OM��������{��3�?���u�ko���� q���|i��?�:�j�qy~~��:�6]����d��ڇʠ��
�1����ƍw�4�51��'M�TnγɫA�=�3�k�z���f�O�G}�M��q4�Ol���}��<�&�������4=��?�]�}�������#q���p�k{����������������v�gk�=����|��,�?p��
[��1�:���+�����k�u+%��ѧ��M5U�j7�����Or��kI���m;���G� Dx����٥w �TU?��ei���K k� ��_��l�츔xs☙㯦��J^�[�H��A�|�nR?90.;�j���UI�4�N
ǟJ5�M!�xG{U�r3�;���u��p����\�D���w�����w ޟ�'�e���vP�3R����@3MKG���������n�c�c寣Ƞ������t�v#{vl�V"������ʁQ��?�'ˇ:]��?��7��i�}�^�p�<���AbWu�}U�o>>>*k��~�~bD�|�˗ٱ}�<)i�K��`�ٝV2����ӣ�G��������H%>N���K�;��������um����B6���\����%� s<����!��)�Y�8)�:ic�Mڌ����� �V�S�DS�a�X]e���5fIiL�!���I(c?/�h�R��-;Jb�������A�>1��Q�4c ټ1L��?� >�!?8< �i�+Z �j��fI�l��?�m�팙�G��i	��&=���7-��Fg#0l\��>6�"D���cp�H������wc.F�AX����w�zP���g�;�u<4�>�3��b%�P���� �I�A{:�lr:�5Es@D�,4���f���Z���]��U��S(C\��6�h��'�21�t��:쭐FA���&�5�,:�1�r,�� �s�,o�m��E��I`��U)o/�$��Wm���,��&�!�~|��"o�MA0��*�x Nhf�7^5�ʠ�k�NP��#��2��	6���U�0��n��+O���՝�bt�0�b�bw��oq��qx�|{��d��͞e�}��5�]�`�2G�FK]	DH���X�#�]3}0�h����&�i#1(��D!ga�(�Jpġl���s��P�\�o*֣60���jd�!�e��ԣ֊���\<	|8���9��D�E)�@R(#�bR�8C
$�W�b��
$���Gu}*rƣ���D7�+��]1���Ԩ��D�S1]É�<��l�0�Mgr�X�� `�gB�Wz��D���R3TvC^u���'�鋾����jr,Wq|�W����D�a�d��%J*C$�a:d�:.����6H�
�����Lg(�I�nsH�:_����˽�q�@��.*��D��q�S�5�>�tC:��a+��|�F�I�Ϙ�h��t�����:��-��l�p�t����ɒ�A7ġ8��(��&0SU�v���#�<F��s�Ɖ�������b�kƧw����s���S�d&�JA~:�Nm��=J��,��闑� 8�����a���� �z83Kg� xB��B�;�v��y*���-v�1aF2�Z�Lۙ�uP*�땋J��yZ�O0GI,+ysI�N����ƧF	@,A:�k�M�	xz��]��67��"��$����-�I�*1��k`�����$�+���yŦ��ڣ�|��z�dv7YP��J����{��|>��
���.�О��4�N��{,[`)���¾"�ᡷ���xBb�KN�kSwG,@���w}�(n�9�̺�Ɗ����"[��_Rp�����f�Zk��v���yxR�P;�WY��.V�tk�R�ڮu:��8���4�ߩwNkݣfu9e]у����vn|m0�,;��A��ѩJ��ӪW����-]��Q�ߒ��́LL�
�U��$a����Sg��-%1 K��q�Z���%�9�QO��'�1�`�Ev��*��_CPd;��� ���SZ_�y��]��X�~|_i�k������2��*G�z�Ҭ����g��N/j�j�Yot�]C�)&	�B��JX�!��dT^�U�ּ��Პح +�Ij�j�rU���n��8�^4jݏ���)�nߓ���In4$C�TP�f� W@o��G��R3�Z��v��nM�����r�S�#PV�w��4�*Gղ�|��`u�W���f������Ċ91e��@6X�������
���1'��`Nf���\U3ُk��c�ݹ���v���r��?q�*3C�/�(�ɹj.�o�GPMy�|>���VD�U�h��1gܹDQU�g�h�q��	�娎�+%F�����b�$�����칚�Ɲ��Nl�����Tvn�7[�l�%	V AK��E���(��%{�v�"�{`�|��i}�F<��@jM��T$�H��P�$f���u�hw�.[n��	�2���tT�/����M�"2�a��\������ ?���n�Ӻ��L!5����f��?����?������v�g���]�ٮ�l��v�GR�/���no� �]��.�l�{�6��F-՜�k�n�ƺ�?�ta���d��������=�H��=�c��<i��f�a�eZo����P]�����ٹ�*U�0�)C�\�EP�����I�ѿ�E{����Z�n�J��4A;1��(*������s��E�y֮��L�u%����_�x����] l�aW��0SEvD���x��m��������#�Lb}D) ������kqV����ya�g���$�^����n�lI�I<�-߭�Fv^�>�Կ�ؗ���k:��#5&�	QtF�͵���o;��;d�:����s�������OO/����I�����Ч�@���k
��ghtl���W���?�Xk`SE�F����I�S��O��O&����c���/_��l�^�&�"�0eh�h�{�_��CY�#��ؐ�'�������}��e�@���@%�ǐ���t���up���J��:���]�)^�z�4ywF�́7x��F�eC����!�@�����b�5�'�&A�
�8��DZԲ�E����؂��!��Iv^���!I��o�M�_
�e'���/@��_��/G��V�q�'&0��d�ͿIl���$�d��#�7;]Py��W5XlF �c���i����5�l��2��a/9x���4��G$���à1������'Q����x�#Ӝ�"}�����$ ��r%��Jb�?C��#�n�(��d<�îA�fu�$@�&W��?�b�:�"��8y����I��ʿ&�]n��<'��!�e�?�,��B�������>���*��w3�5����/���S��-�����x�b���kH��W���C�h6���1��,H3@%�:|�H�<J��%� qCFP��ￓZ��A���g�����/mӈ|�����"��I-�Vd�Ĝ�xY6���t�3]�g�I�Mv�p�ޫ�+B�7�^���N��������ǿ9~��$�ߥY��e�j��a�( h1\�>r{�k��Wl���bŨ\GZZ�6~��((6��0��	�-�×?W"�x��K��礵WS}q��n���=�p/9g,tmd�5�c��N+��%�^��]ǍI���\���MKs4���=�9�+��WHR�i����Xc��H����-�ډ�hlq0��K͏��U�3�p[I� �/��*L��g���<�
mH-x��I<a
�
Ɗ�|q\���?����?��Q�T*Ki/�
�^?�v3�����+�ޮ��MgX&���4�d�I��vt��*P�G��\�¾�`ܕG����������)0F���詔���Y�u��O8�q�7.����8Z���5PziA>g���d%�����\�C��7�p�]�K�;0�
���<�%�c�����{�B1y,1�K�\_�Xfva
�W5��3["�u�=,;�rLȒ������vD�Sm��*`N�c�l��o����l����`��K)�/�$[��Ιd��F^N� �S��۴����EK�ԛ� �[�Mes����v��1����
�� G�^SM�I0L��2}�Nn�ʴ����o����������O2��m��1Ҧ�Ϗ�<��(}��?����@�R���GI?��w�36 `�o�M�u�xb����cS��
$Đ-AsZHߦ@A�b���a��T���o;�`���~K4�vyد�ݛN���^t�5p��ש�-�@$�	z�۲��[gl��+`'�҈�c�1vÔgLũ>Y�w+ͥG�q�ɹ�=$���g�y�w&x'+P�:�7�6>z韚����nD�KD7֛�<�����G)�M�~�������
O�B
�&����{�����t�5�#�j���E���@x���xo��/�c���|2�]W>p�i��
3��Sa�:�&m���*w�����O}��c���O�[��Qҽ�ߛ�7��-���?S�|�?�.�S�t��l6�����H�ҽ�ɉ�O�\y�o1R��}Ƨ�P�[�Џ̓0��vqE�
�UY�R5Em2��@?/hz�����i������]{����.���bhS��ߋ���KU\��CB[Ẅ�ѫ��(����7��� ״�*9�]�/.A���]�Xi��cykKH����D��;b������n0�(*!��<U@u�q�ĭd1c�rh�����gΎ�BE?�ϑ���
w����7jpǈ�O�����CAH�!��tu�og�D`W	O�ү��^=��t �
r>�V�uZ��pk�ȯKD���D1��9oQ�7؇ <y�Q��xP�k��c<p�ɯ�ߏ��ի���S�P����t�����"@��]��b[s�$n�E?�5y���	�L�*�{ޙ��^=����k}�Ҝ���[�� ��-pWmL�"i� �vZ��#�A���p�~��J�~��amNw^�P�����s�E�Sh�ب������DP�g��HX�m��<hc����>0���Mͣ��К��h=��r��Uy��i�����khvㄠ��w�Ξ��G��\nƩU��fc�3 k�g����ďES)��cæ��iq`a�qM+��b:�l=3�f�������_N2�t��a�=1=C)�ޯ/�u[ɮ��'������Q�(���+*�_�&DXD�]RU��v���uR�2u���qT�/a�g�t ����=�7���8�R�ú��I�a��+C;�p,S�炯� e~	�C��Y`<��0B3
�!��n0f���h#w�� ;f�H���!�r�7��<l���_��-�q,-O���֞��i�sۂ]���&3��%�����I�ĉs���qǉ�ܜ8�hP�va��4/h�@���J�
��+b^<�o�x;�J]����;��Z�:>�9�����?�����y��v�Yff�y����gۭ{��������M��kCC1��jw�c�)nՄ��a*�@d�{�[h_^b�S��o<��=���V^��K_��uE��U��H���N��띸ȉn/O;~��=~ 8�>H��Hʛ'l��{O<�^l�ro}Q�A}y`�/$��5YW��F[�de�/�!���ib�쓺ɺ�S4���"�S�1Sl'�Y�F�.���E�nyL�$��ʠ�O&z_:l�m�}�8X��f{�V�qRS~��xJlɱ݈eKp�Fl[��y�E��{�^�8�Z������em\�'=�B��D"��8���v�?������>�s��?�鏿x��)��j�:�bJE�*�"�4�ML�RѬS(����!F`T��`��Q8E!u2���(�C�w|�68}a���^ٚ���˞-�t�u �Wy���7 tv���/nA߻u�"�o�:������NF�;�k_����{�-/s�|��7����u+}yS�]'�)�uV�:�~^��~��ן�'"�]��%��X>=�	4��� >��?#~�����?��ÿ"��Z?�����>���_}�/�� �|3�+���r��G�x��.�X�w?ĈH4��X�"� 5�#YoDJ#p��܁c*��m (�7�(�6"�/.U@��;���?�~u�şD?��?����������C�����o��?�^�Z����-�;o�7���|���+"��7��>��X�A�v��>�O���V�&���Y�й ��fYZ��`K\��mE�Őm&�����E�����V���IG����6\'o�v�h��7�&2���(��/�.���ֹ��*ʏ��i-���̜F�vu*�%\l��l�,�6e@L�SvN'�ɵ�2m�d1/:�����s��_�R�z�l���������-`z�J���L_E31�qb΢B��2����t��UˈS��U��ż���E��L�Z�ϯ�8�SM�����IF�ђ�I:̓��"D�ᢝ�($�S��m��p:<�k��ȃj�B�v�%��925��e�R9�u�5��2�2p&Z<_$܊xK�4�|Nz�xW����؂HW〉y��,*���E�vx&<����������#^O�6?��2�ZwZ=��HB�7KW�N��`���sy��yZ��ٰ6�m��*�.�`JEM|2�Eb��;j�\u�J�uV�WL��ʤ\(�y:nE�I�N�٩����&�@j��Ҩ� ����_:���lR���q�*eB�F���z���S:�T^���T���uRyʹ�M�{e�&	�=b &�w�����J�ϟ�L\�P>>������;ӂ,�z�	���T����弜dV�S.�f�ج*):S��E�F���Ha$6ry����ڲ̤E�ofpދ�H��&t�
9��IF`(0̧;N�;�w�*(��fc�h�I<�)��l�w��"+H,6JI`y}P��U�^��-�"9�
V�蔨	��^�SD��I��X��+���9.�JIL�ؘ�EN�b��(�;�x���Q��?N$��҉R�<�ڈ~R��<Ŵ����`3�Z��b�E���S�܈O���=7=�+�k��ɞ뉞��p ���5�����k�Si5�9bl��8�G��ՐL�6�ZY.��9�	=��@;�z�b%I e��bE���A�*C������%�r����i�Y���KS� ��g&�J�X"������dC �HK8O?i:1��,�|�"4���:�dGL�sbV��S����(�wX���Iz�D��x6U2�b���9Ѐ����4�lw%���lc��7��7��uM·������K��x��J�ۜ [xW?cm7^팍��!xs��a��ڵ[s=ׂ�A���ږ��^��<	�Օ�t���6�An_^�n����KN���m���"�oC���Jr���?^��?�}�>���7ǽ�?����s��ʱ���$+�&ǔg��W�FS=#��Y��G�2�EO�{Չ-���ܛ���њEWx��\Gk�f.��.���u9�i��Lq��Y�|�5�(e��]]	�9"�8����a3Gb	rL�D2��sZ�-��a�I�Au�L��j"dt�\�H�T�f�uM��=�a�(�,�+�XR7�~��C���tv�2х�_�e��f$�N�ѫ��;�ѹm}��i�La�]�N��e�:?���،��R�$m%��4�q�X��*�B�3�S����3	�cxڠ��6��*�:"���n	�e�Bb�J�� t���Q�StT�*!�XϚ}x$qM$�b,���Z�6��e���ª ���p&���E��ѯ_:iXOQ�oe��B�+��t����#}�������3��E���?}ZA����ZA溙�Z>�ͬb�
'����2m~��:���s˄e�)sJm>�����}=��B�o��U�\�/֩�ͱ���&�<����(�r�DW�\:�V�#y�)�8ɲ
Z&uʆT�k�y��a�ɧ5���5
q���$�h+j��N����Bu�Ɉ����"�,e~�(�"M;��di3��=Z/w�"�ӥ&��t���q�,�)צU�Lq �t6�ψ�{��$�hQ��J4��k%-�(w�b��'�$	�HSp�ʠ&�i>/�F�d,Oě6a<I7Uk��|�j!�$����Jx/��K�z*��//��$�cA"f&]�oUr,"�n���xF+q��nIω�+A2���G\w	F�;a���&�X�P�(�9�&yO�_�m�^.P
I+"Kj��F�Y�� ���r���|��yvD7�htR�
�����G��
�Lg�4�!�b�Wj�#�<:� :o=�r]����B�Uy	1���;���G�#��I8!ᡶ�NUn:
&&�S̻(�J�(��X���1�7Je�&ӕ
5�ѓ.�Lא^!�Z��Q+�S�V�ҭ;"CLmi��0��3�VS�T!˙Y��ɴ�K#�z�/A_su��-��5��m�ms���~N�Xe��I�����.��F��X8�G�����/���j�f��#ot�^�6�l��/o��@oB��{�?F�y���������{^�נ��m�س�.x}�����Fc�C���ޤK�R���Mp/��Z��Ӧ��ju=��(ss�,�SleuB��_�z���]���.�{���lF�p���mHO�E|y*�� 7�����Zc�t_�]������#n����]��㿉
u�6.���.����_|��|�
�z�ѣ��'�N{�����ޑ�l���gz��,���m�-h��a�.=��#/2�+��ߌ�3��M��M��}�Iѽ�V�#�>(�
7�#Y7�B=�n�zd���Ⱥ�#�}�7�D�wqCW�#릾�G�M�Q���z�Y繣YO4YG�������鞥���]<���/d���0Bb'tA�A�9����?��.Lf}��������)w������ /�h�/����I�/� ������+2i�}�⫋»�*۪��1��ȱ�8-���ђz_�u#wA/������|�2.��T�ף{�>�J�;s۲��s���p�0��[�,(��[w�W��������M��E6�Kڸd����<e��8�;A�U/تl�;��8f?�?���G��.���74&~�{����"��A���`��[�p�6 �x�U9�T&;��J�Â�N3����N��jY������Msb�8M��S���[�.��t~8aGR1����<��dh^º���5�.�J��L��3<fjx��@�ζ�V���YTC�s��,�%dX�j�����x���~���k���BWj�j�_%0#P/������p��?7���6�z�#0A������o��ڸ���������c/�?��>�y��e���2�����z��\��.��O"g����/S������������_����tj~�{�������Q�������U�6�C~"����}���9���?;�>�l�x�+|���$@���������ǂ��;A�/���{��}~��g�����s���N���	V �E`�����^�?v���`�w'��?s<X�����������	��A�:���g������?���o�S���Q��g�������c�Y�	���_���=���'�����Nd[
�-ٖ��m���l��_`��?�?�+�_��/�������aO�?� �������!��������b/�?��?�����f#�7���?�������G�3��q2������� \��\�҇�D�ޤPS�J���FF5D��٬S�{�4�����G�����c�?B������w��<u���w5b.E`�>��*�2��g�)��5�T���8+���/�h5��%��b��(\ӕiCJ�a�F�'a"�$����Ų��c�M �Y����i=�6gB*+S��'�'�~y���������~������}������������O�_6��5�~
/.�����?<K��Qt��c�ZW8d*�P�6,;]7�Y�۱�X���_�/u��LV�t�갗��n��]	��K��ČDc����$"jx�jI�����4�d�Rh'>��iv��Cy6��������`��'�)�U�:�?���;U���g~�}w�#}�p@QAQ�{��@�^���f��w��OR�N�|J�i3kΪ������/��*P��_P��_������Ѐ��'������o���������ٮ���u�RfZW������>\���u���M&��+��_o�Q/w�T�R5{��M��8;����f����寇%I���4��Ai+�t4�ΥM�\$����uح�D��C.��r�8�ڂј����U�Q�=�����Jmtu�庞�x��U��2�|�i�W��w]}Ђ��"+�����ͶQ��Y�����^h>�����P�|vf�ݚa\3�ڇHa��Rv��Z�#5o��q$gF���򩔦�N��.ɝum��˭>���(���Q�vDj����%>���9����r���	����������&�����h�g����$�� N������o�#'A�`�#����0��P�/����_��c��9�����$�?�����/&`���@���7�ߋ���/@�����/�����Ür��{�?��q���0�0��o�?\��?���� ��/H�� ��g��OO �O(p����������� ���;� �����郗g��&����������
��8P(�_7�� �������?�����*C
�?���������&��PRp����?�4�?� �?@��� ����7��@�aB��/��PR��o�G�P�W��;πm���������<�x�����������v�iԦ�ڛ�M�_w�=���������܌��S8�`�Y���L�j@��O~Ԁȇt[U��^7;mȖ���(m��q'ium�v5�%��e����O�(�Lm�?-�A�X�ļ��t��b�;��k@�kȿ���E �T��ռsq�Ʋ4U�DuK=��|2Mq]�&[����i5Uk�@+�[�4!UV����,df�z@V{��yʆ�(��hȸN�O���οD�?���������4�,�����#���;�?!��$�?4��"������,������?B�G����
���P��������_H�h�D�8�/���?B���"�����P��[��4��Bp�� ����$�?������� 9��+� N�"H�Q8�h���y�؈eiY	&�h$�Q$�/��"K�D�?����W	�ω��������ow����o�=���Ɔjk����f����f���qn�4���uo�u�4��3~-���8��Tߤ�=�A̼���q�U��p�)�iG�W�N��fȖ��$;d���I���>^,����|��B��0��gyƖ�g�]�fG�8O��8Q�S�M�~j�s7��{7/��NHX���gq(t�ϖp�[0HX���"��������u��E_�o	��_q�H�����t^��f]+OhJ//x4�kκ�4��ú�r����>�?�[9	[��e�$��Fs���J�4�J�S��C��K~��''g}�s�]R����Zb:��r�&�U�L��qͳ��~d��7�_���
_��W���W�� �/��*P��_P��_������Ѐŀ�'迂��\�_\����� �C;*�%z>ȼ-���u�����G���H=��(-�t����mrK�����Q�:��r��`1��}�a.�I�e.��e);�bw��MW\�^R��,�f#HҺ_c�q�ٶ�弢-��y�U�iH�k���^���G��z55��	���zU-�+��R��B��^��r�5Y6י��eê��#݊6\�UQ0��F�T��;Z��Wl���M���`&�]H��ڏ���E��� �e2�7hө�B'1���7���z.�YO=-��ɉz�&��֡٤���i�dͩx`��g�S�Q�����)�'?��T�����r#��/�����C�a�0��CO/�������{3��E	�?��/���`����I뿀ĀBQ���d������#A
���� ���+�ELdF`��GYᠰ�������o��G�8���jM\%&�UՎ�uT�Q�l��|'��z�
�=���6{���w�rU-������*HX��{�?�a�g��COw(�"8��������� ��Y��W�Y��������pȗ"��O���ty�%�y�f�(
$�S"�I��
�B:`&`?$����/����#��.ƑZg{�=�>M��n���[4߇��/�+��ӱ>��۸�˴2�;q�kZ�߯����f��� �Y�a����������a������/�����_�����5������{	��������y����ث����� ��1���OL����}z��E�N�}�����W� �� ������?������q��q(�������M����	��uLї�[���p���_�� �����/ŷ�?���/��� �cA���^bb�\�������/�/B�����JEW��/W����,{�lYWj��ν\�_%s���vӜ�<��L#����ѳ/��q�hv�e�)��JHF=c`k�cV�h;[�[��D����6ƶ<~��v}������U`k��U����?��s`�]�4������cl�W��Q����x��E�H�8>d��?�U��{�"���2�H���"-Y�F���&����,��X���v���9S�ӓe�3�ڪ��N����Zu]f�B�㉗'
S�Dv����!�վF�4���2W�*?D���c�#�Ҫ�O��X���^�^D���1T�V��&ʖ[)5�����E�5��tË�nN��zM�-�:u�w.?��Zq崛���<�FȈ�:*�R8�fMOܕℯ��@��}\���2�]/��ZV�/�Z�l�kXI�3(7��~�-�@����o����_:�װP��o�G�?�7���������O�M�O	��B�7�/@�/,x���W������[�S:Mʚy����X,ݛ������_fO>��r���(�g�cMW��s��:S����ļ6����b�E�z;�>6x�~~��5����[��^Ƌ������m�<\Lv��z�BS�T}�Җ��{�q�\�\�=��i$g85s!�)5���Zm�\�Ҳ�E#�PU4��f�-��q��ӕ�Ԟ�;�7Nf�7潞ִUޤʵg9\�m-�U�e�Wu���u���yV�.�JC���n���fi
��4yc�MV�0�P���+Uў�u��#���͏��PTFǪmx˭�i���o��(�etV��R���%I����xy_9T&�؊�BCܬ��i��n�Vn+ҾK�v���٩�+�a�x���v�
��̝�o�����Cs � (�����#���;��������>1��$���s��߰�-��կ������a�c:�6?3���e��>ݞ������4�G{pm�B]C �&@=4���~;@��� �a�"���f�����9 �90�F綸_�S�﹣�6Kc�Კ4��`~Z��F���ğ�)k��lKѳ�%�U��N��(��a7I�A���o� �� �{r �x�F����4��p�a�M�|����9gib�97u�7݇~� �j��+-��UE�/�B�J5Oϫ�� Vf'���2#,*�:lJ�A_:�f�џ���k�65�#E�(����2�����a @��������[�����Y� � ����q��8����?���+���;�O����)�6�� ����	�Ͻz/<����$�?�\ĠO���Gt �-G�F�ˁ³\�1�(Op< F���3B
�yA�)q�	�o�7�<���o4m�ͦ�����l�Ը���.3s�\�U=Ν��f�O��:�C%u=�����\E�t���rS�Ø����v��P]��ׯ��,�Lko���ZlȢ@-�����k=:\��=������ a����š��?[¡o� a��W����Q�������}1�!H����#�_;�l�X�Z��ZZ7*+5��R��'�y��*�>f'51������E��w�ι̷J=v��Z��r���pJS�>AV�c�ږ��^�w�<%GSݶ���nqlRs�kX{}���������U������[X��W�����O 	�/��*P��_P��_������ЀE��w�g��������k=��7�?���s�Ae'��C7�d-v�_\�Uӏ����*�tm��M&��u �+=�����I/(���Bي|�6J���1<5���`f��I��6�ٌ"�I�A#�č�8W��L�F\�8�Y3��wZ=䤶�ɩ[m7�������í�\���W�r[��vZlT��_��U�z�X��"�V��v蘇���2s�v�P;�bK�)g�⺭��Fz[,���V��t��������á��䉕��O����8���J�l.�u�Y��c�Jm,f/�Yi���&NjC��ܢ�Aں��ukH����?c���0�d��o���w��?�����?��`��������h�g��/�CsWҀ���;�����X �_a�+�������&�	����G���R��{�?��e����#^���N����?@�������?�����`�� ����	���8`��BH�������`����/���W A�1����|�� �������y�?���,}����b��b���ߛ�������|@���������O�9������E�1
�E��O�2-MЄaC>���E^	%Z�C��f��ޕw'�$���)r]��U�6��w=o$!s߆y�<:!ց����}3%���eW�̔�_�P*yE�2"R��8��i-��,)9-���~F������>�)��>����ú�O�K�nj0;4�2����e����]��Oת��L���ڭ�r3ץƪݾg'U�*��W�,΃a��>7f�sS'iiܬ���^�们)�Q����.���1���N2�|�����)��Ծ�����C�����#^8Q:���L�?~��0t
�OS{��������ӤC����4)������������g�����w:�������$3��h��"5eĤT��j��P*Lg�̈Q��(��
�Ad�j��1t
�������0����`t~cX�a�f7���^gt�,V�Uғ~�i\�X�����-�OV�w�QKR�7���E��2��x搨�V�r?�5&�`$�(���Ku*����`�轖36�b�!�pq#�8�'�\�+������G��8K���T���3�������S����gb�?
��_�Y�?��M1���|�����r :2���<2������ڳ��B'���!�H1���t�O=���� :!���=
�������A���������������� t��k��!�E���k�'���l��|��A���8��t
����?����? �����������%�Y���r�i�t�����y����h_�z[g0��VU�e��xͿo4��9w.zYRL��D���)^�5+�	ZN�3��\�K�y6�q�󀭔��P�}6�����G��j�`�ҵZUrC�����!_�п��oB�U�ʑk?�fP��7����ou�ۈa�Y�e֠��4Qf���br=M��������5F�%%�@�y��w�L:�W�$+�1q�흗b�j�����v�ڛ�ͫ���N������_���A�쿭���7~=���_��;	�O����<��ǧD�N���w�����!(>�)>�)>�)>�)��c��H������������m����������?�����S������ѫ����U���-��׭^�|�%��ʾ�[��ͧX��K��O#�~\{��R��[��w�im����}�/-���S;��gB��k��̲��o�vG*dW�{�ތ�ʍ�۩�B��b���<ՎD��De�7cP��jGj�]��z�D�q�$L#7iD"(8��b��
e<�)����<����G)�!��y��?S^
M�0]�;՞]Yp�cP�OR^:7&��εP�*�~�3[��@.�弬�#U��p�2�6Wr�Z���Ҫ��I�#T�<[ ��������_]�VU�G���|UtC_�4�U�̗��3�}N(	Y�iU�Ayv7���Z��u���A_���,�U�~h:�'u�*u�RSd�r3M��~�t�����T?�[�s.WJ������BԒzIo��i{V�^ivޖ�T
�Y�o7�j�!��Jd��B�u[|����$�?j�����B'`�M���l���(��m���y"��_��:%��F
ũ���d��R���fRd*�U 	Y%�p��QU&��iN�E%5���,�������t
�������?�����}eX�,�n$��Z�pm7�p����Ϟ3��8�Wo�t� ���of2Z�Z���B��~/5�J��J���8/�qe�Lo���B����bD�u���꒑�u+�����̓zJ/x��Z�d����V:��?>��xt���3�Eߣ�)����w<:	����8� �G�&�x�����?���G���������������&�ak����twZq$՚�5Ն��o�?�¤�RO�I��k+7}��׮2s���m�����T'[���v��k���@(���N�?ҁ�6�M�'�l��S���V:�����G���U9�:��}��@���W���x���������_q�'�����m�c�I����cR��wz���#�OO?����Y� �2�g7\e��$CZ����M����=�m���[-�@����� ��?��ضg��@��Z���k�x��{ ��bd��n�O�W<�)��=%�CgD4��I�|�*yk�n�Z�^���Z�W��7���s�ڵ��qd��zk:�lͳf}��>l�����	�����"���慠* �t)/ ��'o�0P�e�����=!�d�{Ϲ�����K�L��δ�n��ݪ�G'6��p.�-�ޔ��CM��pex��@�RS,I�2Yv�y>����{U8�E�0�\�bvztw�c��^�a�Iض띕Ȥyӛ��"����L�/��쯦���݈?���'V��|��W�?ͱ�.��)��b�?}�=_9�>�@I��+g� �i�NsA�r�%�O�'�n�n.*�
-^�4hy�Ȁ�%��:�t�D�PƋ�#����h�	M�\���`���m���lɺa�(9|X��w��V}.	 ޗ9�.�x_��<��[% ��g�a]�-�-L�1ǳ���(�!�Ȁt�M; #�jL�A��-� 4�T��*��O�1E����sֲ����i[�"�|���ԇ
o��Qr��-�ƿk����ol���j( ��%+&D����4T�C*�-Bc$�.0,��}g�/��}'�� U���]�e�$Ё��d�ic�a�'l6@5�- ;����DT/�1��xKhxL[�]W	e������������|Á�W��ڏ/�F�,�WF���������#�>��H6��CȐͯa]�=歛���md�8�1�<0�%��XC�V��e��~�F��e|��cߥ�?�Hl��[]E�����w�c���x(/*��B6}���c����6?�F����	�к�߁�9�4W��-�}:�#�Fi�,s�Pʳp��VS�G�9�;��e���Pԅ"�H���\�d��[%Ev^H��8p�h���2���'�P�v �ª1���o,�.B��Q�4�ew>6�d�\���'?�@⹖��=E�)gx:�O�,z���#ھ�]P��>��V�z�ki�3M����L��}�=��xO����%����_����|P}�>*C�����Ǫ�e3�_;*X��f?`#֨5⎱l�|���@E5}iM;��@�����ݐ.]F�2�1�u!.+����
!:bڑQ����x�V^�M�p1����Ɓh�.��Dڍ���U�[�A�����,�a���X��ǩS�s�K�>��H(�[�����n�l,kZ�a�X��#n>�Fas��+N���c;�l�7L-�-����'Y�}���i6��BQ8G�@�C���:�s���!��d;��B�$ފ��m���>7�9"��-1���c�d��k�Y��T2
���{s�L[��ă|]�����o|��8�-�Vb����r��%"��ߥ��^�?w�a��а����?�Kq��?4~K���Z0�b8*��Cq45]��������p�s{4�3YG��x5��	5	�ZdT��3��Ț#l�Zñ-��>�Y6����U�*	=5���Z&�<ؖZ=���x�bOe�O�{
G���
�,u�x*��*K�+G�iM1��B˲��4�SdR�tz��pDi܈�eZa��YZSF�(��Y6e:-ߺS"�0��[��3�L���Od�0�@/�;F�~{Z�ȮƳ���M��ͭ��1��)\�K*++锬(
�fHN�5���J�YY��i692��@FV4|��̠��d!�AJN�u�P@x��e�w����7����Vw%~|�[���om�z,��C�6���I1ʸF>�ħ�����Ʈ�x���[9���� դ_����'U�4�����J�T�s���n_���s�ۥvU��+,!�eݯ^��%���F�|��n�rWk�]��;Wj=�>�b���w�$��)�Uo5ùI{�%u{.{��I9u�����UZ{+z�Dё��X��}���s1�t�N�]��<��`[����9��ԧ=�J����~yߟ����M��zK�B^(Ր�+I�'���|�&�s�9#��IB����W��j�F�T�\����L&�8Β\�N��m�p��3|~�$�;�ͻѶzI��n��XF���X��K�ۚ���[�*j��F�n����BwTG����1J���n�3��~P��A�r�l��w��o���ߖ�����s�w���X�	�6��6���5�2�Ͱ猪�6�(N�X�r9�j$�.|A���ABNa^R�!�ܕ�?���p���r���O��c쇕�V�]�shi�-�r���[���t쟭���7O�Ɉc�{�=p�n��
*��Pw&�&�x�Ç�3��O���?�ƾ����hv`�Û	w�e�����(��M�$�R��0�����CЧ�H*��Tdw�_ې�xI�#�q= �v~sǰ< ������N.�=��T�*�:6�/߁����ad�b�O̹��J�V}��˛`Qn�Y%l=�}�T�Н�ɳ� �/޶�ݖ(����og����_�<��/̶=�+$�!�\8�>j��:��r=�yx��P�Â�@�~;{��J�j
v��b��=���QeޔW�ׁ3{-j�*�g������C}�4g����ъ�6Ѱ���9�fv�-ָɿnN>*����F��/X_;3|��s`��+����l��t��i. �	e���K�[������`?���������4�Пah��t�eb�?� �f"��g�{��C%�@6�������e�XqN��W�;c�����7�+������#9�t���4��=���kU��
���Bul#����HG��
� ��{d�m�^� [�	�%���?>C�-��9i���_���q̣���`
.�	���˗��S���,Pߢ�0J����we�iA�}�h���b�L�Rۨ}i+E�K�cu���!�{gv��z��|/{wvv����3�W��@P�i�=�\Γ�I�wӲ�"��ޛ�%��fYjuQ���i['��S+�0�d�|XP�K��M"G����t��(���P��|�o�2�h��`��+�T|Q��Xm&т0�!�03�ơ������/p~��]�S8]NcrIS���,�3�V$%=#�1H�bdS_\b�s1M-�O�X� W�D�'qP
�)�)a��^����$��H��H3�"/7��Jx��u���P��b�!���/�[6%��3�g�#��[��k�s����o��߼��&/��:�����8�%6?3!�W�P��ɮ���M�/;���ٶ]�Xa�;YA�s,o���Q����9�cw��зǵ��z~`�|��n�G�/���׋h|؏V	�P�BC�	TfКAfN������>ͥ�C��;��fy�VFЊ�O!�V9*��H|��[���� е�8:�ha޷t-����M�lqMU�]�P���Z�(��u�u�zC
�*Jh"P�3�t8�b�392w�/�8�/��1kz�w�gVW��힡�S�_�
��w�����x��d�NU��}����KD���p��ehh�>��K2Fbz��*��" ��`�$bDke���[����k�%��0�ոd���*�D�\15���
��m���iS�Dȟ��It����Xƴ�23��>s:�Y:�h�-%��#�?3�`0��`0��`0������, 0 