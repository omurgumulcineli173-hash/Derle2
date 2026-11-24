// DUKTUR RP - Tam Roleplay Gamemode (SA-MP 0.3.7, ek plugin yok)
// Gerekli klasorler: scriptfiles/duktur/hesap  ve  scriptfiles/duktur/karakter
#include <a_samp>
#define strncmp(%0,%1,%2) strcmp(%0,%1,false,%2)
native Float:floatstr(const string[]);

#define MOR 0xA855F7FF
#define KIRMIZI 0xFF5555FF
#define YESIL 0x55FF55FF
#define SARI 0xFFFF55FF
#define BEYAZ 0xFFFFFFFF
#define MAXMULK 60
#define MAXRAPOR 60
#define MAXBAS 60
#define AKTIF if(!Aktif[playerid]) return Hata(playerid,"Once bir karakter secmelisin.")
#define KOMUT(%0) if(!strcmp(cmd,%0,true))

enum { D_YOK, D_KAYIT, D_GIRIS, D_SLOT, D_SLOTMENU, D_SIL, D_AD, D_SOYAD, D_YAS, D_CINS, D_SKIN, D_DOGUM, D_MENU, D_ARACAL, D_ARACLARIM, D_MESLEK, D_ENV, D_MARKET, D_BASVURU, D_RAPORTUR, D_RAPORMETIN, D_TEL, D_GPS, D_A_GERI, D_A_OYUNCU, D_A_ISLEM, D_A_SEBEP, D_A_RAPOR, D_A_RCEVAP, D_A_SUNUCU, D_A_DUYURU, D_A_ARAC, D_A_VEH }

new const MeslekAd[12][] = {"Issiz","Polis","Saglik Gorevlisi","Mekanik","Taksi Soforu","Otobus Soforu","Tir Soforu","Copcu","Belediye Calisani","Gazeteci","Isletmeci","Serbest Calisan"};
new const MeslekMaas[12] = {0,2500,2500,1800,1500,1500,2000,1200,1600,1700,2200,1000};
new const MeslekBas[12] = {0,1,1,0,0,0,0,0,0,0,0,0};
new const BirlikAd[6][] = {"Yok","LSPD","LSMD","Mekanik Birligi","Belediye","Basin Yayin"};
new const EsyaAd[8][] = {"Su","Ekmek","Ilk Yardim Kiti","Tamir Kiti","Sigara","Benzin Bidonu","Maske","Radyo"};
new const EsyaFiyat[8] = {20,30,300,500,50,200,150,400};
new const EsyaAgirlik[8] = {1,1,2,5,1,8,1,2};
new const AracModel[10] = {411,560,405,426,401,410,400,521,463,468};
new const AracAd[10][] = {"Infernus","Sultan","Sentinel","Premier","Bravura","Manana","Landstalker","FCR-900","Freeway","Sanchez"};
new const AracFiyat[10] = {220000,60000,30000,25000,12000,9000,40000,25000,15000,8000};
new const SkinE[6] = {14,21,22,23,29,60};
new const SkinK[6] = {9,10,11,12,13,31};
new const Kanlar[8][] = {"A+","A-","B+","B-","AB+","AB-","0+","0-"};
new const BasarimAd[9][] = {"Ilk Karakter","Ilk Meslek","Ilk Arac","Ilk Ev/Isyeri","10 Saat Oyun","50 Saat Oyun","100 Saat Oyun","Milyoner","Ilk Birlik"};
new const RaporTur[7][] = {"Oyuncu Sikayeti","Admin Sikayeti","Hile Bildirimi","Bug Bildirimi","Teknik Destek","Ceza Itirazi","Oneri"};
new const BasvuruTur[5][] = {"Polis","Saglik Gorevlisi","Silah Ruhsati","Isletme","Etkinlik"};
new const GpsAd[4][] = {"All Saints Hastanesi","LSPD","Belediye","Unity Station"};
new const Float:GpsPos[4][3] = {{1177.5,-1323.5,14.0},{1554.4,-1675.5,16.2},{1481.0,-1772.3,18.8},{1759.0,-1898.1,13.6}};

new bool:Giris[MAX_PLAYERS], bool:Aktif[MAX_PLAYERS], Deneme[MAX_PLAYERS];
new hSifre[MAX_PLAYERS], hAdm[MAX_PLAYERS], hBan[MAX_PLAYERS], hWarn[MAX_PLAYERS], hMute[MAX_PLAYERS], hJail[MAX_PLAYERS], hBanEnd[MAX_PLAYERS];
new hBanSebep[MAX_PLAYERS][48], hSlot[MAX_PLAYERS][4][34];
new tSlot[MAX_PLAYERS], tAd[MAX_PLAYERS][24], tSoyad[MAX_PLAYERS][24], tYas[MAX_PLAYERS], tCins[MAX_PLAYERS], tDogum[MAX_PLAYERS][24], tRapor[MAX_PLAYERS];
new cSlot[MAX_PLAYERS], cKey[MAX_PLAYERS][34], cAd[MAX_PLAYERS][24], cSoyad[MAX_PLAYERS][24], cDogum[MAX_PLAYERS][24], cNot[MAX_PLAYERS][80];
new cYas[MAX_PLAYERS], cCins[MAX_PLAYERS], cSkin[MAX_PLAYERS], cBoy[MAX_PLAYERS], cKilo[MAX_PLAYERS], cKan[MAX_PLAYERS];
new cCash[MAX_PLAYERS], cBank[MAX_PLAYERS], cLevel[MAX_PLAYERS], cXP[MAX_PLAYERS], cMin[MAX_PLAYERS], cJob[MAX_PLAYERS];
new cFac[MAX_PLAYERS], cRank[MAX_PLAYERS], cPhone[MAX_PLAYERS], cBelge[MAX_PLAYERS], cBas[MAX_PLAYERS];
new cGDay[MAX_PLAYERS], cWDay[MAX_PLAYERS], cGMin[MAX_PLAYERS], cWMin[MAX_PLAYERS], cGor[MAX_PLAYERS], cEarn[MAX_PLAYERS], cSpent[MAX_PLAYERS];
new cInv[MAX_PLAYERS][8], cMulk[MAX_PLAYERS][3], cVM[MAX_PLAYERS][3], cVP[MAX_PLAYERS][3][10], cVid[MAX_PLAYERS][3];
new cArk[MAX_PLAYERS][5][24];
new Float:cX[MAX_PLAYERS], Float:cY[MAX_PLAYERS], Float:cZ[MAX_PLAYERS];
new vSahip[MAX_VEHICLES], Davet[MAX_PLAYERS], Aranan[MAX_PLAYERS], Konusuyor[MAX_PLAYERS], bool:Katildi[MAX_PLAYERS];
new Etkinlik[96], Duyuru[96];

new mOn[MAXMULK], mTip[MAXMULK], mFiyat[MAXMULK], mOwner[MAXMULK][34], mPick[MAXMULK], bool:mHas[MAXMULK], Text3D:mLabel[MAXMULK];
new Float:mX[MAXMULK], Float:mY[MAXMULK], Float:mZ[MAXMULK];
new rOn[MAXRAPOR], rTur[MAXRAPOR], rDurum[MAXRAPOR], rSahip[MAXRAPOR][24], rMetin[MAXRAPOR][96], rCevap[MAXRAPOR][96];
new bOn[MAXBAS], bTur[MAXBAS], bDurum[MAXBAS], bKey[MAXBAS][34];

// ---------- Karakter secim menusu (textdraw) ----------
new sSecim[MAX_PLAYERS], bool:sAcik[MAX_PLAYERS], PlayerText:sTD[MAX_PLAYERS][12];
new sAd[MAX_PLAYERS][4][48], sSkin[MAX_PLAYERS][4], sLvl[MAX_PLAYERS][4], sNakit[MAX_PLAYERS][4], sBanka[MAX_PLAYERS][4], sMes[MAX_PLAYERS][4], sDak[MAX_PLAYERS][4];

forward Dakika();
forward SpawnDuzelt(playerid);
public SpawnDuzelt(playerid) {
  if (!IsPlayerConnected(playerid) || !Aktif[playerid]) return 1;
  SetPlayerSkin(playerid, cSkin[playerid]);
  ResetPlayerMoney(playerid); GivePlayerMoney(playerid, cCash[playerid]);
  return 1;
}
forward KickGec(playerid);
public KickGec(playerid) { Kick(playerid); return 1; }

// ---------- Yardimcilar ----------
stock Hata(playerid, const s[]) { SendClientMessage(playerid, KIRMIZI, s); return 1; }
stock Bilgi(playerid, const s[]) { SendClientMessage(playerid, MOR, s); return 1; }
stock Hash(const s[]) { new h = 5381; for (new i = 0; s[i]; i++) h = h * 33 + s[i]; return h ^ 0x44525021; }
stock Kirp(s[]) { new l = strlen(s); while (l > 0 && (s[l-1] == '\n' || s[l-1] == '\r')) s[--l] = 0; }
stock Temizle(s[]) { for (new i = 0; s[i]; i++) if (s[i] == '|' || s[i] == '=' || s[i] == '\n' || s[i] == '\r') s[i] = ' '; }
stock IsimGecerli(const s[]) {
  new l = strlen(s);
  if (l < 2 || l > 16) return 0;
  for (new i = 0; i < l; i++) if (!((s[i] >= 'a' && s[i] <= 'z') || (s[i] >= 'A' && s[i] <= 'Z'))) return 0;
  return 1;
}
stock Buyut(s[]) { for (new i = 0; s[i]; i++) { if (i == 0 && s[i] >= 'a' && s[i] <= 'z') s[i] -= 32; else if (i > 0 && s[i] >= 'A' && s[i] <= 'Z') s[i] += 32; } }
stock Tok(const s[], &idx, out[], len = 64) {
  new l = strlen(s), o = 0;
  while (idx < l && s[idx] == ' ') idx++;
  while (idx < l && s[idx] != ' ' && o < len - 1) out[o++] = s[idx++];
  out[o] = 0;
  return o;
}
stock Kalan(const s[], idx, out[], len = 96) { while (s[idx] == ' ') idx++; strmid(out, s, idx, strlen(s), len); Temizle(out); }
stock Split(const s[], out[][48], max) {
  new i = 0, pos = 0, e;
  while (i < max) {
    e = strfind(s, "|", false, pos);
    if (e == -1) { strmid(out[i], s, pos, strlen(s), 48); i++; break; }
    strmid(out[i], s, pos, e, 48); i++; pos = e + 1;
  }
  return i;
}
stock KV(const line[], k[], v[]) {
  new e = strfind(line, "="), l = strlen(line);
  if (e < 1) return 0;
  while (l > e + 1 && (line[l-1] == '\n' || line[l-1] == '\r')) l--;
  strmid(k, line, 0, e, 24); strmid(v, line, e + 1, l, 104);
  return 1;
}
stock WI(File:h, const k[], v) { new s[64]; format(s, sizeof s, "%s=%d\n", k, v); fwrite(h, s); }
stock WS(File:h, const k[], const v[]) { new s[160]; format(s, sizeof s, "%s=%s\n", k, v); fwrite(h, s); }
stock Para(playerid) { return GetPlayerMoney(playerid); }
stock RPAd(playerid, out[]) { format(out, 48, "%s %s", cAd[playerid], cSoyad[playerid]); }
stock Buldu(const nick[]) { new n[MAX_PLAYER_NAME]; for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i)) { GetPlayerName(i, n, sizeof n); if (!strcmp(n, nick, true)) return i; } return -1; }
stock IDGecerli(id) { return (id >= 0 && id < MAX_PLAYERS && IsPlayerConnected(id) && Aktif[id]); }
stock CezaLog(const hedef[], const tur[], const yetkili[], const sebep[]) {
  new s[200], File:h = fopen("duktur/ceza.log", io_append);
  if (!h) return;
  format(s, sizeof s, "%s|%s|%s|%s\n", hedef, tur, yetkili, sebep);
  fwrite(h, s); fclose(h);
}

// ---------- Hesap ----------
stock HesapYol(playerid, out[]) { new n[MAX_PLAYER_NAME]; GetPlayerName(playerid, n, sizeof n); format(out, 64, "duktur/hesap/%s.ini", n); }
stock HesapYukle(playerid) {
  new f[64], line[160], k[24], v[104];
  HesapYol(playerid, f);
  if (!fexist(f)) return 0;
  new File:h = fopen(f, io_read);
  if (!h) return 0;
  while (fread(h, line)) {
    if (!KV(line, k, v)) continue;
    if (!strcmp(k, "pass")) hSifre[playerid] = strval(v);
    else if (!strcmp(k, "admin")) hAdm[playerid] = strval(v);
    else if (!strcmp(k, "ban")) hBan[playerid] = strval(v);
    else if (!strcmp(k, "banend")) hBanEnd[playerid] = strval(v);
    else if (!strcmp(k, "bansebep")) format(hBanSebep[playerid], 48, "%s", v);
    else if (!strcmp(k, "warn")) hWarn[playerid] = strval(v);
    else if (!strcmp(k, "mute")) hMute[playerid] = strval(v);
    else if (!strcmp(k, "jail")) hJail[playerid] = strval(v);
    else if (!strncmp(k, "slot", 4)) { new s = k[4] - '0'; if (s >= 0 && s < 4) format(hSlot[playerid][s], 34, "%s", v); }
  }
  fclose(h);
  return 1;
}
stock HesapKaydet(playerid) {
  new f[64], k[8];
  HesapYol(playerid, f);
  new File:h = fopen(f, io_write);
  if (!h) return;
  WI(h, "pass", hSifre[playerid]); WI(h, "admin", hAdm[playerid]); WI(h, "ban", hBan[playerid]); WI(h, "banend", hBanEnd[playerid]);
  WS(h, "bansebep", hBanSebep[playerid]); WI(h, "warn", hWarn[playerid]); WI(h, "mute", hMute[playerid]); WI(h, "jail", hJail[playerid]);
  for (new s = 0; s < 4; s++) { format(k, sizeof k, "slot%d", s); WS(h, k, hSlot[playerid][s]); }
  fclose(h);
}

// ---------- Karakter ----------
stock KYol(const key[], out[]) { format(out, 64, "duktur/karakter/%s.k", key); }
stock KarakterSifirla(p) {
  cAd[p][0] = 0; cSoyad[p][0] = 0; cDogum[p][0] = 0; cNot[p][0] = 0; cKey[p][0] = 0;
  cYas[p] = 0; cCins[p] = 0; cSkin[p] = 0; cBoy[p] = 0; cKilo[p] = 0; cKan[p] = 0; cCash[p] = 0; cBank[p] = 0;
  cLevel[p] = 1; cXP[p] = 0; cMin[p] = 0; cJob[p] = 0; cFac[p] = 0; cRank[p] = 0; cPhone[p] = 0; cBelge[p] = 0; cBas[p] = 0;
  cGDay[p] = 0; cWDay[p] = 0; cGMin[p] = 0; cWMin[p] = 0; cGor[p] = 0; cEarn[p] = 0; cSpent[p] = 0;
  cX[p] = 0.0; cY[p] = 0.0; cZ[p] = 0.0;
  for (new i = 0; i < 8; i++) cInv[p][i] = 0;
  for (new i = 0; i < 3; i++) { cMulk[p][i] = 0; cVM[p][i] = 0; cVP[p][i][0] = 0; cVid[p][i] = 0; }
  for (new i = 0; i < 5; i++) cArk[p][i][0] = 0;
}
stock ListeOku(const s[], out[], n) {
  new p = 0, e;
  for (new i = 0; i < n; i++) { out[i] = strval(s[p]); e = strfind(s, ",", false, p); if (e == -1) break; p = e + 1; }
}
stock KarakterYukle(p, const key[]) {
  new f[64], line[200], k[24], v[104];
  KarakterSifirla(p);
  KYol(key, f);
  if (!fexist(f)) return 0;
  new File:h = fopen(f, io_read);
  if (!h) return 0;
  format(cKey[p], 34, "%s", key);
  while (fread(h, line)) {
    if (!KV(line, k, v)) continue;
    if (!strcmp(k, "ad")) format(cAd[p], 24, "%s", v);
    else if (!strcmp(k, "soyad")) format(cSoyad[p], 24, "%s", v);
    else if (!strcmp(k, "dogum")) format(cDogum[p], 24, "%s", v);
    else if (!strcmp(k, "not")) format(cNot[p], 80, "%s", v);
    else if (!strcmp(k, "yas")) cYas[p] = strval(v);
    else if (!strcmp(k, "cins")) cCins[p] = strval(v);
    else if (!strcmp(k, "skin")) cSkin[p] = strval(v);
    else if (!strcmp(k, "boy")) cBoy[p] = strval(v);
    else if (!strcmp(k, "kilo")) cKilo[p] = strval(v);
    else if (!strcmp(k, "kan")) cKan[p] = strval(v);
    else if (!strcmp(k, "cash")) cCash[p] = strval(v);
    else if (!strcmp(k, "bank")) cBank[p] = strval(v);
    else if (!strcmp(k, "level")) cLevel[p] = strval(v);
    else if (!strcmp(k, "xp")) cXP[p] = strval(v);
    else if (!strcmp(k, "min")) cMin[p] = strval(v);
    else if (!strcmp(k, "job")) cJob[p] = strval(v);
    else if (!strcmp(k, "fac")) cFac[p] = strval(v);
    else if (!strcmp(k, "rank")) cRank[p] = strval(v);
    else if (!strcmp(k, "phone")) cPhone[p] = strval(v);
    else if (!strcmp(k, "belge")) cBelge[p] = strval(v);
    else if (!strcmp(k, "bas")) cBas[p] = strval(v);
    else if (!strcmp(k, "gday")) cGDay[p] = strval(v);
    else if (!strcmp(k, "wday")) cWDay[p] = strval(v);
    else if (!strcmp(k, "gmin")) cGMin[p] = strval(v);
    else if (!strcmp(k, "wmin")) cWMin[p] = strval(v);
    else if (!strcmp(k, "gor")) cGor[p] = strval(v);
    else if (!strcmp(k, "earn")) cEarn[p] = strval(v);
    else if (!strcmp(k, "spent")) cSpent[p] = strval(v);
    else if (!strcmp(k, "x")) cX[p] = float(strval(v));
    else if (!strcmp(k, "y")) cY[p] = float(strval(v));
    else if (!strcmp(k, "z")) cZ[p] = float(strval(v));
    else if (!strcmp(k, "inv")) ListeOku(v, cInv[p], 8);
    else if (!strcmp(k, "mulk")) ListeOku(v, cMulk[p], 3);
    else if (!strncmp(k, "veh", 3)) {
      new s = k[3] - '0', e = strfind(v, "|");
      if (s >= 0 && s < 3 && e > 0) { cVM[p][s] = strval(v); strmid(cVP[p][s], v, e + 1, strlen(v), 10); }
    }
    else if (!strncmp(k, "ark", 3)) { new s = k[3] - '0'; if (s >= 0 && s < 5) format(cArk[p][s], 24, "%s", v); }
  }
  fclose(h);
  return 1;
}
stock KarakterKaydet(p) {
  if (!Aktif[p]) return;
  new f[64], s[96], k[8], Float:x, Float:y, Float:z;
  KYol(cKey[p], f);
  cCash[p] = GetPlayerMoney(p);
  if (GetPlayerInterior(p) == 0 && GetPlayerVirtualWorld(p) == 0 && GetPlayerState(p) != PLAYER_STATE_SPECTATING) { GetPlayerPos(p, x, y, z); cX[p] = x; cY[p] = y; cZ[p] = z; }
  new File:h = fopen(f, io_write);
  if (!h) return;
  WS(h, "ad", cAd[p]); WS(h, "soyad", cSoyad[p]); WS(h, "dogum", cDogum[p]); WS(h, "not", cNot[p]);
  WI(h, "yas", cYas[p]); WI(h, "cins", cCins[p]); WI(h, "skin", cSkin[p]); WI(h, "boy", cBoy[p]); WI(h, "kilo", cKilo[p]); WI(h, "kan", cKan[p]);
  WI(h, "cash", cCash[p]); WI(h, "bank", cBank[p]); WI(h, "level", cLevel[p]); WI(h, "xp", cXP[p]); WI(h, "min", cMin[p]);
  WI(h, "job", cJob[p]); WI(h, "fac", cFac[p]); WI(h, "rank", cRank[p]); WI(h, "phone", cPhone[p]); WI(h, "belge", cBelge[p]); WI(h, "bas", cBas[p]);
  WI(h, "gday", cGDay[p]); WI(h, "wday", cWDay[p]); WI(h, "gmin", cGMin[p]); WI(h, "wmin", cWMin[p]); WI(h, "gor", cGor[p]);
  WI(h, "earn", cEarn[p]); WI(h, "spent", cSpent[p]); WI(h, "x", floatround(cX[p])); WI(h, "y", floatround(cY[p])); WI(h, "z", floatround(cZ[p]));
  format(s, sizeof s, "%d,%d,%d,%d,%d,%d,%d,%d", cInv[p][0], cInv[p][1], cInv[p][2], cInv[p][3], cInv[p][4], cInv[p][5], cInv[p][6], cInv[p][7]);
  WS(h, "inv", s);
  format(s, sizeof s, "%d,%d,%d", cMulk[p][0], cMulk[p][1], cMulk[p][2]);
  WS(h, "mulk", s);
  for (new i = 0; i < 3; i++) { if (cVM[p][i]) { format(k, sizeof k, "veh%d", i); format(s, sizeof s, "%d|%s", cVM[p][i], cVP[p][i]); WS(h, k, s); } }
  for (new i = 0; i < 5; i++) { if (cArk[p][i][0]) { format(k, sizeof k, "ark%d", i); WS(h, k, cArk[p][i]); } }
  fclose(h);
}
stock Basarim(p, bit) {
  if (cBas[p] & (1 << bit)) return;
  cBas[p] |= (1 << bit); cBank[p] += 500;
  new s[96]; format(s, sizeof s, "BASARIM KAZANDIN: %s (+$500 banka)", BasarimAd[bit]);
  SendClientMessage(p, YESIL, s);
}

// ---------- Mulk ----------
stock MulkYenile(i) {
  new s[96];
  if (mPick[i] != -1) DestroyPickup(mPick[i]);
  if (mHas[i]) Delete3DTextLabel(mLabel[i]);
  mPick[i] = -1; mHas[i] = false;
  if (!mOn[i]) return;
  if (mOwner[i][0] == '-') { mPick[i] = CreatePickup(1273, 1, mX[i], mY[i], mZ[i], -1); format(s, sizeof s, "%s SATILIK\n$%d\n/mulksatinal", mTip[i] ? "ISYERI" : "EV", mFiyat[i]); }
  else { mPick[i] = CreatePickup(1272, 1, mX[i], mY[i], mZ[i], -1); format(s, sizeof s, "%s\nSahibi: %s\n/gir", mTip[i] ? "ISYERI" : "EV", mOwner[i]); }
  mLabel[i] = Create3DTextLabel(s, 0xA855F7FF, mX[i], mY[i], mZ[i] + 0.8, 15.0, 0, 0);
  mHas[i] = true;
}
stock MulkKaydet() {
  new s[200], File:h = fopen("duktur/mulk.dat", io_write);
  if (!h) return;
  for (new i = 0; i < MAXMULK; i++) if (mOn[i]) {
    format(s, sizeof s, "%d|%d|%s|%d|%.2f|%.2f|%.2f\n", i, mTip[i], mOwner[i], mFiyat[i], mX[i], mY[i], mZ[i]);
    fwrite(h, s);
  }
  fclose(h);
}
stock MulkYukle() {
  new line[200], p[7][48];
  for (new i = 0; i < MAXMULK; i++) { mOn[i] = 0; mPick[i] = -1; mHas[i] = false; }
  if (!fexist("duktur/mulk.dat")) return;
  new File:h = fopen("duktur/mulk.dat", io_read);
  if (!h) return;
  while (fread(h, line)) {
    Kirp(line);
    if (Split(line, p, 7) < 7) continue;
    new i = strval(p[0]);
    if (i < 0 || i >= MAXMULK) continue;
    mOn[i] = 1; mTip[i] = strval(p[1]); format(mOwner[i], 34, "%s", p[2]); mFiyat[i] = strval(p[3]);
    mX[i] = floatstr(p[4]); mY[i] = floatstr(p[5]); mZ[i] = floatstr(p[6]);
    MulkYenile(i);
  }
  fclose(h);
}
stock YakinMulk(playerid) {
  for (new i = 0; i < MAXMULK; i++) if (mOn[i] && IsPlayerInRangeOfPoint(playerid, 3.0, mX[i], mY[i], mZ[i])) return i;
  return -1;
}

// ---------- Rapor / Basvuru ----------
stock RaporKaydet() {
  new s[300], File:h = fopen("duktur/rapor.dat", io_write);
  if (!h) return;
  for (new i = 0; i < MAXRAPOR; i++) if (rOn[i]) { format(s, sizeof s, "%d|%d|%s|%s|%s\n", rTur[i], rDurum[i], rSahip[i], rMetin[i], rCevap[i]); fwrite(h, s); }
  fclose(h);
}
stock RaporYukle() {
  new line[300], n = 0;
  if (!fexist("duktur/rapor.dat")) return;
  new File:h = fopen("duktur/rapor.dat", io_read);
  if (!h) return;
  while (fread(h, line) && n < MAXRAPOR) {
    Kirp(line);
    new e1 = strfind(line, "|"), e2 = strfind(line, "|", false, e1 + 1), e3 = strfind(line, "|", false, e2 + 1), e4 = strfind(line, "|", false, e3 + 1);
    if (e1 < 0 || e2 < 0 || e3 < 0 || e4 < 0) continue;
    rOn[n] = 1; rTur[n] = strval(line); rDurum[n] = strval(line[e1 + 1]);
    strmid(rSahip[n], line, e2 + 1, e3, 24); strmid(rMetin[n], line, e3 + 1, e4, 96); strmid(rCevap[n], line, e4 + 1, strlen(line), 96);
    n++;
  }
  fclose(h);
}
stock BasvuruKaydet() {
  new s[100], File:h = fopen("duktur/basvuru.dat", io_write);
  if (!h) return;
  for (new i = 0; i < MAXBAS; i++) if (bOn[i]) { format(s, sizeof s, "%d|%d|%s\n", bTur[i], bDurum[i], bKey[i]); fwrite(h, s); }
  fclose(h);
}
stock BasvuruYukle() {
  new line[100], p[3][48], n = 0;
  if (!fexist("duktur/basvuru.dat")) return;
  new File:h = fopen("duktur/basvuru.dat", io_read);
  if (!h) return;
  while (fread(h, line) && n < MAXBAS) {
    Kirp(line);
    if (Split(line, p, 3) < 3) continue;
    bOn[n] = 1; bTur[n] = strval(p[0]); bDurum[n] = strval(p[1]); format(bKey[n], 34, "%s", p[2]); n++;
  }
  fclose(h);
}
stock BasvuruUygula(p) {
  for (new i = 0; i < MAXBAS; i++) {
    if (!bOn[i] || bDurum[i] != 2 || strcmp(bKey[i], cKey[p], true)) continue;
    if (bTur[i] == 0) { cJob[p] = 1; cFac[p] = 1; cRank[p] = 1; }
    else if (bTur[i] == 1) { cJob[p] = 2; cFac[p] = 2; cRank[p] = 1; }
    else if (bTur[i] == 2) cBelge[p] |= 4;
    bDurum[i] = 4; BasvuruKaydet();
    new s[80]; format(s, sizeof s, "%s basvurun KABUL edildi!", BasvuruTur[bTur[i]]);
    SendClientMessage(p, YESIL, s);
  }
}

// ---------- Oyun ----------
stock Maas(p) {
  new maas = MeslekMaas[cJob[p]], vergi = 0;
  for (new i = 0; i < 3; i++) { if (cMulk[p][i]) vergi += mFiyat[cMulk[p][i] - 1] / 100; if (cVM[p][i]) for (new j = 0; j < 10; j++) if (AracModel[j] == cVM[p][i]) vergi += AracFiyat[j] / 200; }
  cBank[p] += maas - vergi; cEarn[p] += maas;
  new s[128]; format(s, sizeof s, "MAAS GUNU: Maas $%d, Vergi $%d, Banka: $%d", maas, vergi, cBank[p]);
  SendClientMessage(p, SARI, s);
}
stock PlayerText:TDYazi(playerid, Float:x, Float:y, const text[], Float:lx, Float:ly, font, align) {
  new PlayerText:t = CreatePlayerTextDraw(playerid, x, y, text);
  PlayerTextDrawLetterSize(playerid, t, lx, ly);
  PlayerTextDrawFont(playerid, t, font);
  PlayerTextDrawAlignment(playerid, t, align);
  PlayerTextDrawColor(playerid, t, -1);
  PlayerTextDrawSetShadow(playerid, t, 0);
  PlayerTextDrawSetOutline(playerid, t, 1);
  PlayerTextDrawBackgroundColor(playerid, t, 0x000000FF);
  PlayerTextDrawSetProportional(playerid, t, 1);
  return t;
}
stock PlayerText:TDResim(playerid, Float:x, Float:y, Float:w, Float:h, const spr[], color, sec) {
  new PlayerText:t = CreatePlayerTextDraw(playerid, x, y, spr);
  PlayerTextDrawFont(playerid, t, 4);
  PlayerTextDrawTextSize(playerid, t, w, h);
  PlayerTextDrawColor(playerid, t, color);
  PlayerTextDrawBackgroundColor(playerid, t, 0);
  PlayerTextDrawSetSelectable(playerid, t, sec);
  return t;
}
stock SlotBilgiOku(playerid) {
  new f[64], line[200], k[24], v[104], ad[24], soyad[24];
  for (new i = 0; i < 4; i++) {
    sAd[playerid][i][0] = 0; sSkin[playerid][i] = 0; sLvl[playerid][i] = 0; sNakit[playerid][i] = 0; sBanka[playerid][i] = 0; sMes[playerid][i] = 0; sDak[playerid][i] = 0;
    if (!hSlot[playerid][i][0]) continue;
    KYol(hSlot[playerid][i], f);
    ad[0] = 0; soyad[0] = 0;
    sLvl[playerid][i] = -1;
    if (fexist(f)) {
      new File:h = fopen(f, io_read);
      if (h) {
        sLvl[playerid][i] = 1;
        while (fread(h, line)) {
          if (!KV(line, k, v)) continue;
          if (!strcmp(k, "ad")) format(ad, sizeof ad, "%s", v);
          else if (!strcmp(k, "soyad")) format(soyad, sizeof soyad, "%s", v);
          else if (!strcmp(k, "skin")) sSkin[playerid][i] = strval(v);
          else if (!strcmp(k, "level")) sLvl[playerid][i] = strval(v);
          else if (!strcmp(k, "cash")) sNakit[playerid][i] = strval(v);
          else if (!strcmp(k, "bank")) sBanka[playerid][i] = strval(v);
          else if (!strcmp(k, "job")) sMes[playerid][i] = strval(v);
          else if (!strcmp(k, "min")) sDak[playerid][i] = strval(v);
        }
        fclose(h);
      }
    }
    if (ad[0]) format(sAd[playerid][i], 48, "%s %s", ad, soyad);
    else format(sAd[playerid][i], 48, "%s", hSlot[playerid][i]);
  }
}
stock SlotYenile(playerid) {
  new s[256], i = sSecim[playerid], m = sMes[playerid][i];
  if (m < 0 || m > 11) m = 0;
  format(s, sizeof s, "Slot %d / 4", i + 1);
  PlayerTextDrawSetString(playerid, sTD[playerid][7], s);
  if (hSlot[playerid][i][0]) {
    if (sLvl[playerid][i] < 0) format(s, sizeof s, "~r~%s~n~~n~~w~Karakter dosyasi~n~bulunamadi!", sAd[playerid][i]);
    else format(s, sizeof s, "~y~%s~n~~n~~w~Seviye: ~g~%d~n~~w~Meslek: ~g~%s~n~~w~Nakit: ~g~$%d~n~~w~Banka: ~g~$%d~n~~w~Sure: ~g~%d dk", sAd[playerid][i], sLvl[playerid][i], MeslekAd[m], sNakit[playerid][i], sBanka[playerid][i], sDak[playerid][i]);
    PlayerTextDrawSetString(playerid, sTD[playerid][4], s);
    PlayerTextDrawSetPreviewModel(playerid, sTD[playerid][3], sSkin[playerid][i]);
    PlayerTextDrawShow(playerid, sTD[playerid][3]);
    PlayerTextDrawSetString(playerid, sTD[playerid][9], "OYNA");
    PlayerTextDrawShow(playerid, sTD[playerid][10]);
    PlayerTextDrawShow(playerid, sTD[playerid][11]);
  } else {
    PlayerTextDrawSetString(playerid, sTD[playerid][4], "~g~+ YENI KARAKTER~n~~n~~w~Bu slot bos.~n~Karakter olusturmak~n~icin OLUSTUR'a dokun.");
    PlayerTextDrawHide(playerid, sTD[playerid][3]);
    PlayerTextDrawSetString(playerid, sTD[playerid][9], "OLUSTUR");
    PlayerTextDrawHide(playerid, sTD[playerid][10]);
    PlayerTextDrawHide(playerid, sTD[playerid][11]);
  }
}
stock SecimKapat(playerid) {
  if (!sAcik[playerid]) return;
  sAcik[playerid] = false;
  for (new i = 0; i < 12; i++) PlayerTextDrawDestroy(playerid, sTD[playerid][i]);
  CancelSelectTextDraw(playerid);
}
stock ShowSlots(playerid) {
  SecimKapat(playerid);
  SlotBilgiOku(playerid);
  SetPlayerCameraPos(playerid, 1760.0, -1910.0, 40.0); SetPlayerCameraLookAt(playerid, 1759.0, -1898.0, 13.5);
  sTD[playerid][0] = TDResim(playerid, 170.0, 110.0, 300.0, 250.0, "LD_SPAC:white", 0x000000CC, 0);
  sTD[playerid][1] = TDResim(playerid, 170.0, 110.0, 300.0, 22.0, "LD_SPAC:white", 0xA855F7FF, 0);
  sTD[playerid][2] = TDYazi(playerid, 320.0, 114.0, "KARAKTER SECIMI", 0.3, 1.3, 2, 2);
  sTD[playerid][3] = TDYazi(playerid, 180.0, 138.0, "_", 0.5, 1.0, 5, 1);
  PlayerTextDrawTextSize(playerid, sTD[playerid][3], 100.0, 140.0);
  PlayerTextDrawBackgroundColor(playerid, sTD[playerid][3], 0);
  PlayerTextDrawSetPreviewRot(playerid, sTD[playerid][3], -10.0, 0.0, 20.0, 1.0);
  sTD[playerid][4] = TDYazi(playerid, 290.0, 142.0, "_", 0.28, 1.3, 1, 1);
  sTD[playerid][5] = TDResim(playerid, 185.0, 288.0, 32.0, 32.0, "LD_BEAT:left", -1, 1);
  sTD[playerid][6] = TDResim(playerid, 423.0, 288.0, 32.0, 32.0, "LD_BEAT:right", -1, 1);
  sTD[playerid][7] = TDYazi(playerid, 320.0, 297.0, "_", 0.3, 1.3, 2, 2);
  sTD[playerid][8] = TDResim(playerid, 185.0, 326.0, 130.0, 24.0, "LD_SPAC:white", 0x22AA44FF, 1);
  sTD[playerid][9] = TDYazi(playerid, 250.0, 330.0, "OYNA", 0.25, 1.2, 2, 2);
  sTD[playerid][10] = TDResim(playerid, 325.0, 326.0, 130.0, 24.0, "LD_SPAC:white", 0xCC3333FF, 1);
  sTD[playerid][11] = TDYazi(playerid, 390.0, 330.0, "SIL", 0.25, 1.2, 2, 2);
  for (new i = 0; i < 12; i++) PlayerTextDrawShow(playerid, sTD[playerid][i]);
  sAcik[playerid] = true;
  if (sSecim[playerid] < 0 || sSecim[playerid] > 3) sSecim[playerid] = 0;
  SlotYenile(playerid);
  SelectTextDraw(playerid, 0xFFD966FF);
}
stock Oyna(playerid, slot) {
  if (!KarakterYukle(playerid, hSlot[playerid][slot])) return Hata(playerid, "Karakter dosyasi bulunamadi.");
  cSlot[playerid] = slot; Aktif[playerid] = true;
  for (new i = 0; i < 3; i++) if (cMulk[playerid][i] && (!mOn[cMulk[playerid][i] - 1] || strcmp(mOwner[cMulk[playerid][i] - 1], cKey[playerid], true))) cMulk[playerid][i] = 0;
  if ((cX[playerid] == 0.0 && cY[playerid] == 0.0) || (cX[playerid] == 1759.0 && cY[playerid] == -1898.0)) { cX[playerid] = 1481.0; cY[playerid] = -1772.3; cZ[playerid] = 18.8; }
  SetSpawnInfo(playerid, NO_TEAM, cSkin[playerid], cX[playerid], cY[playerid], cZ[playerid] + 0.5, 0.0, 0, 0, 0, 0, 0, 0);
  TogglePlayerSpectating(playerid, 0);
  return 1;
}
stock KarakterOlustur(p, g) {
  new f[64];
  KarakterSifirla(p);
  format(cAd[p], 24, "%s", tAd[p]); format(cSoyad[p], 24, "%s", tSoyad[p]); format(cDogum[p], 24, "%s", tDogum[p]);
  cYas[p] = tYas[p]; cCins[p] = tCins[p]; cSkin[p] = tCins[p] ? SkinK[g] : SkinE[g];
  cBoy[p] = 160 + random(35); cKilo[p] = 55 + random(40); cKan[p] = random(8); cPhone[p] = 100000 + random(899999);
  cBank[p] = 5000; cCash[p] = 500; cBelge[p] = 1; cInv[p][0] = 2; cInv[p][1] = 2; cBas[p] = 1;
  format(cKey[p], 34, "%s_%s", cAd[p], cSoyad[p]);
  format(hSlot[p][tSlot[p]], 34, "%s", cKey[p]);
  cX[p] = 1481.0; cY[p] = -1772.3; cZ[p] = 18.8;
  Aktif[p] = true; KarakterKaydet(p); Aktif[p] = false;
  KYol(cKey[p], f);
  if (!fexist(f)) {
    hSlot[p][tSlot[p]][0] = 0;
    Hata(p, "Karakter kaydedilemedi! Sunucuda scriptfiles/duktur/karakter klasoru yok.");
    ShowSlots(p);
    return 0;
  }
  HesapKaydet(p);
  Oyna(p, tSlot[p]);
  return 1;
}
stock Env_Ekle(p, item, adet) {
  new w = 0;
  for (new i = 0; i < 8; i++) w += cInv[p][i] * EsyaAgirlik[i];
  if (w + adet * EsyaAgirlik[item] > 40) return 0;
  cInv[p][item] += adet; return 1;
}
stock AracCikar(playerid, s) {
  new Float:x, Float:y, Float:z, Float:a;
  GetPlayerPos(playerid, x, y, z); GetPlayerFacingAngle(playerid, a);
  new v = CreateVehicle(cVM[playerid][s], x + 3.0, y, z + 0.5, a, -1, -1, -1);
  SetVehicleNumberPlate(v, cVP[playerid][s]); SetVehicleToRespawn(v);
  vSahip[v] = playerid + 1; cVid[playerid][s] = v;
}
stock AracPark(playerid, s) { if (cVid[playerid][s]) { vSahip[cVid[playerid][s]] = 0; DestroyVehicle(cVid[playerid][s]); cVid[playerid][s] = 0; } }
stock Kimlik(playerid, hedef) {
  new s[300];
  format(s, sizeof s, "KIMLIK KARTI\n\nAd Soyad: %s %s\nYas: %d\nDogum: %d.%d.%d\nUyruk: T.C.\nBoy/Kilo: %d cm / %d kg\nKan Grubu: %s\nTelefon: %d", cAd[hedef], cSoyad[hedef], cYas[hedef], 1 + cPhone[hedef] % 28, 1 + (cPhone[hedef] / 7) % 12, 2026 - cYas[hedef], cBoy[hedef], cKilo[hedef], Kanlar[cKan[hedef]], cPhone[hedef]);
  ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "DUKTUR RP - Kimlik", s, "Kapat", "");
}

public Dakika() {
  new now = gettime();
  for (new i = 0; i < MAX_PLAYERS; i++) {
    if (!IsPlayerConnected(i) || !Aktif[i]) continue;
    cMin[i]++; cXP[i] += 10; cGMin[i]++; cWMin[i]++;
    if (cGDay[i] != now / 86400) { cGDay[i] = now / 86400; cGMin[i] = 1; cGor[i] &= ~1; }
    if (cWDay[i] != now / 604800) { cWDay[i] = now / 604800; cWMin[i] = 1; cGor[i] &= ~2; }
    while (cXP[i] >= cLevel[i] * 100) {
      cXP[i] -= cLevel[i] * 100; cLevel[i]++; cBank[i] += 1000; SetPlayerScore(i, cLevel[i]);
      new m[80]; format(m, sizeof m, "Seviye atladin! Yeni seviye: %d (+$1000 banka)", cLevel[i]); SendClientMessage(i, MOR, m);
    }
    if (cGMin[i] >= 30 && !(cGor[i] & 1)) { cGor[i] |= 1; cBank[i] += 2000; SendClientMessage(i, YESIL, "Gunluk gorev tamamlandi: +$2000 banka!"); }
    if (cWMin[i] >= 300 && !(cGor[i] & 2)) { cGor[i] |= 2; cBank[i] += 15000; SendClientMessage(i, YESIL, "Haftalik gorev tamamlandi: +$15000 banka!"); }
    if (cMin[i] >= 600) Basarim(i, 4);
    if (cMin[i] >= 3000) Basarim(i, 5);
    if (cMin[i] >= 6000) Basarim(i, 6);
    if (cBank[i] + GetPlayerMoney(i) >= 1000000) Basarim(i, 7);
    if (cMin[i] % 60 == 0) Maas(i);
    if (cMin[i] % 5 == 0) KarakterKaydet(i);
    if (hJail[i] > 0) { hJail[i]--; if (hJail[i] == 0) { SetPlayerInterior(i, 0); SetPlayerPos(i, 1554.4, -1675.5, 16.2); SendClientMessage(i, YESIL, "Hapis cezan bitti."); } }
    if (hMute[i] > 0) hMute[i]--;
    BasvuruUygula(i);
  }
  return 1;
}

// =====================================================================
//  DUKTUR RP - ULTIMATE ADMIN CONTROL CENTER V3.0  (SA-MP, plugin yok)
//  Yetkiler: Level 15..2 | Rol verme: sadece Level 14-15 (/setadmin)
//  Ilk admin: oyunda /rcon login <sifre> yaz, sonra /setadmin [id] 15
// =====================================================================
forward AdminSaniye();
forward GMXYap();
public GMXYap() { SendRconCommand("gmx"); return 1; }

#define ADM(%0,%1) if (!strcmp(cmd, %0, true)) if (!Yetki(playerid, %1)) return 1; else
#define HEDEF(%0) Tok(cmdtext, idx, a1, sizeof a1); if (!HedefAl(playerid, a1, h, %0)) return 1
#define ALIAS(%0,%1) if (!strcmp(cmd, %0, true)) format(cmd, sizeof cmd, %1)

new const AdmAd[16][] = {"Member","Member","Orginazasyon Lideri","Member","Admin Asistan","Server Admin","Advanced Admin","Rising Admin","Manager Admin","The Vice Chief Admin","The Chef Admin","Responsible Admin","Minister Admin","Project Staff Manager","The Project Manager","Project Producer"};
new const ABtn[8][] = {"OYUNCULAR","KOMUTLAR","RAPORLAR","SUNUCU","ARACLAR","EKONOMI","LOGLAR","KAPAT"};
new const ATileAd[8][] = {"AKTIF OYUNCU","AKTIF ADMIN","ACIK RAPOR","ORT. PING","UPTIME","TOPLAM BAN","TOPLAM MUTE","TOPLAM JAIL"};
new const AIslemMetin[] = "Oyuncu bilgisi\nYanina isinlan\nYanima getir\nIyilestir\nCanlandir\nDondur\nDonmayi coz\nIzle (spectate)\nUyari ver\nSustur\nSusturmayi kaldir\nHapse gonder\nHapisten cikar\nKick at\nBan at";
new const AIsLv[15] = {4,4,4,4,4,4,4,4,4,4,4,5,5,4,6};
new const ASunLv[7] = {4,5,5,7,7,7,7};
new const AToplamAd[5][] = {"healall","reviveall","freezeall","unfreezeall","bringall"};
new const AParaAd[6][] = {"givemoney","removemoney","setmoney","givebank","removebank","setbank"};

// Format: "SEVIYE KATEGORI /komut kullanim - aciklama"  (kat: 0 genel,1 oyuncu/ceza,2 arac,3 ekonomi,4 karakter,5 sunucu,6 rapor)
new const AKm[][] = {
  "02 0 /admin (/adminmenu) - Admin panelini ac",
  "02 0 /ahelp - Yetkine uygun komutlar",
  "00 0 /admins (/stafflist) - Cevrimici yetkililer",
  "02 0 /a [mesaj] (/adminchat) - Admin sohbeti",
  "04 0 /serverinfo (/serverstatus) - Sunucu bilgisi",
  "04 0 /coords - Koordinatini goster",
  "05 0 /gotocoords [x] [y] [z] - Koordinata isinlan",
  "05 0 /ann [mesaj] (/announce) - Sunucu duyurusu",
  "05 0 /clearchat - Sohbeti temizle",
  "06 0 /god - Olumsuzluk ac/kapat",
  "06 0 /fly - Jetpack ver / al",
  "07 0 /adminlog - Son admin islemleri",
  "04 1 /players (/serverplayers) - Oyuncu listesi",
  "04 1 /playerinfo [id] - Oyuncu bilgisi",
  "04 1 /goto [id] (/tp) - Oyuncuya isinlan",
  "04 1 /gethere [id] (/bring /tphere) - Oyuncuyu getir",
  "04 1 /spec [id] , /specoff - Oyuncuyu izle",
  "04 1 /freeze [id] , /unfreeze [id] - Dondur / coz",
  "04 1 /heal [id] , /armor [id] , /revive [id] - Iyilestir / zirh / canlandir",
  "05 1 /slay [id] - Oyuncuyu oldur",
  "04 1 /kick [id] [sebep] - Sunucudan at",
  "04 1 /warn [id] [sebep] - Uyari ver",
  "04 1 /mute [id] [dk] [sebep] , /unmute [id] - Sustur / kaldir",
  "05 1 /jail [id] [dk] [sebep] , /unjail [id] - Hapis / cikar",
  "06 1 /tempban [id] [dk] [sebep] - Sureli ban",
  "07 1 /ban [id] [sebep] - Kalici ban",
  "07 1 /unban [hesap_nick] - Ban kaldir",
  "07 1 /healall /reviveall /freezeall /unfreezeall - Toplu islemler",
  "10 1 /bringall - Herkesi yanina getir",
  "05 2 /veh [400-611] (/car) - Arac olustur",
  "05 2 /dv (/delveh) - Aracini sil",
  "05 2 /repair (/fix) , /flip - Tamir / cevir",
  "05 2 /vehicleinfo - Arac bilgisi",
  "07 2 /setplate [plaka] - Plaka ayarla",
  "08 3 /givemoney /removemoney /setmoney [id] [miktar] - Nakit",
  "08 3 /givebank /removebank /setbank [id] [miktar] - Banka",
  "06 3 /giveitem [id] [esya 0-7] [adet] - Esya ver",
  "07 3 /clearinventory [id] - Envanteri temizle",
  "06 4 /setskin [id] [model] - Skin degistir",
  "07 4 /setjob [id] [0-11] , /removejob [id] - Meslek",
  "07 4 /setgang [id] [birlik 0-5] [rutbe] , /removegang [id] - Birlik",
  "14 4 /setadmin [id] [0,2,4-15] (/setgroup) - Rol ver / al",
  "07 5 /weather [0-45] , /time [0-23] - Hava / saat",
  "07 5 /serverlogs - Ceza logu",
  "10 5 /serverrestart [sn] - Sunucuyu yeniden baslat",
  "04 6 /reports , /reportinfo [no] - Raporlari gor",
  "04 6 /acceptreport [no] , /replyreport [no] [mesaj] - Rapor cevapla",
  "04 6 /denyreport [no] [mesaj] , /closereport [no] - Reddet / kapat"
};

new bool:aAcik[MAX_PLAYERS], PlayerText:aTD[MAX_PLAYERS][47], aSon[MAX_PLAYERS], aHedef[MAX_PLAYERS], aIslem[MAX_PLAYERS], aRap[MAX_PLAYERS], aSpecP[MAX_PLAYERS];
new bool:aGod[MAX_PLAYERS], bool:aSpec[MAX_PLAYERS], Float:aPos[MAX_PLAYERS][4], aInt[MAX_PLAYERS], aBasla, aSy, aSayi[3];

// ---------- Temel yardimcilar ----------
stock AL(p) { if (p < 0 || p >= MAX_PLAYERS || !IsPlayerConnected(p)) return 0; if (IsPlayerAdmin(p)) return 15; return hAdm[p]; }
stock Yetki(p, lv) {
  if (AL(p) < lv) { Hata(p, "Bu komutu kullanma yetkin yok."); return 0; }
  new t = GetTickCount();
  if (t - aSon[p] < 400 && t - aSon[p] >= 0) { Hata(p, "Cok hizli komut kullaniyorsun."); return 0; }
  aSon[p] = t; return 1;
}
stock AdminMesaj(const s[], lv = 2) { for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && Giris[i] && AL(i) >= lv) SendClientMessage(i, 0xC084FCFF, s); return 1; }
stock Ad(p, out[]) { if (Aktif[p]) RPAd(p, out); else GetPlayerName(p, out, 48); return 1; }
stock HedefAl(p, const s[], &h, const kul[]) {
  if (s[0] < '0' || s[0] > '9') { Hata(p, kul); return 0; }
  h = strval(s);
  if (h < 0 || h >= MAX_PLAYERS || !IsPlayerConnected(h) || !Giris[h]) { Hata(p, "Oyuncu bulunamadi."); return 0; }
  return 1;
}
stock Ust(p, h) { if (!IsPlayerAdmin(p) && AL(h) > AL(p)) { Hata(p, "Senden yuksek yetkili birine islem yapamazsin."); return 1; } return 0; }
stock Sebep(s[]) { if (!s[0]) format(s, 96, "Belirtilmedi"); return 1; }
stock ALog(admin, const komut[], hedef, const detay[], const kaynak[] = "Oyun") {
  new File:h = fopen("duktur/adminlog.log", io_append);
  if (!h) return 0;
  new y, mo, d, hh, mm, ss, an[MAX_PLAYER_NAME], hn[MAX_PLAYER_NAME], s[256];
  getdate(y, mo, d); gettime(hh, mm, ss);
  GetPlayerName(admin, an, sizeof an);
  if (hedef >= 0 && IsPlayerConnected(hedef)) GetPlayerName(hedef, hn, sizeof hn); else format(hn, sizeof hn, "-");
  format(s, sizeof s, "%02d.%02d.%d %02d:%02d|%s|%s|%s|%s|%s\n", d, mo, y, hh, mm, an, kaynak, komut, hn, detay);
  fwrite(h, s); fclose(h);
  return 1;
}
stock CezaK(a, h, const tur[], const sebep[]) { new an[MAX_PLAYER_NAME], hn[MAX_PLAYER_NAME]; GetPlayerName(a, an, sizeof an); GetPlayerName(h, hn, sizeof hn); CezaLog(hn, tur, an, sebep); return 1; }

// ---------- Ceza ve oyuncu islemleri (komut + panel ortak) ----------
stock ActKick(a, h, const sebep[], const k[] = "Oyun") {
  if (a == h) { Hata(a, "Kendine islem yapamazsin."); return 0; }
  if (Ust(a, h)) return 0;
  new s[220], n[48], an[48]; Ad(h, n); Ad(a, an);
  format(s, sizeof s, "[ADMIN] %s, %s adli oyuncuyu sunucudan atti. Sebep: %s", an, n, sebep);
  SendClientMessageToAll(KIRMIZI, s);
  CezaK(a, h, "KICK", sebep); ALog(a, "kick", h, sebep, k);
  SetTimerEx("KickGec", 600, false, "i", h);
  return 1;
}
stock ActBan(a, h, dk, const sebep[], const k[] = "Oyun") {
  if (a == h) { Hata(a, "Kendine islem yapamazsin."); return 0; }
  if (Ust(a, h)) return 0;
  new s[220], n[48], an[48], su[24]; Ad(h, n); Ad(a, an);
  hBan[h] = 1; hBanEnd[h] = (dk > 0) ? gettime() + dk * 60 : 0;
  format(hBanSebep[h], 48, "%s", sebep); HesapKaydet(h);
  if (dk > 0) format(su, sizeof su, "%d dk", dk); else format(su, sizeof su, "Kalici");
  format(s, sizeof s, "[ADMIN] %s, %s adli oyuncuyu banladi (%s). Sebep: %s", an, n, su, sebep);
  SendClientMessageToAll(KIRMIZI, s);
  CezaK(a, h, "BAN", sebep);
  format(s, sizeof s, "%s | %s", su, sebep); ALog(a, "ban", h, s, k);
  SetTimerEx("KickGec", 600, false, "i", h);
  return 1;
}
stock UnbanYap(const nick[]) {
  if (strfind(nick, "/") != -1 || strfind(nick, "\\") != -1 || strfind(nick, "..") != -1) return -1;
  new yol[80], L[40][96], c = 0, i, ok = 0, line[160];
  format(yol, sizeof yol, "duktur/hesap/%s.ini", nick);
  if (!fexist(yol)) return -1;
  new File:h = fopen(yol, io_read);
  if (!h) return -1;
  while (fread(h, line) && c < 40) { Kirp(line); format(L[c], 96, "%s", line); c++; }
  fclose(h);
  h = fopen(yol, io_write);
  if (!h) return -1;
  for (i = 0; i < c; i++) {
    if (!strncmp(L[i], "ban=", 4)) { if (strval(L[i][4])) ok = 1; format(L[i], 96, "ban=0"); }
    else if (!strncmp(L[i], "banend=", 7)) format(L[i], 96, "banend=0");
    format(line, sizeof line, "%s\n", L[i]); fwrite(h, line);
  }
  fclose(h);
  return ok;
}
stock ActMute(a, h, dk, const sebep[], const k[] = "Oyun") {
  if (a == h) { Hata(a, "Kendine islem yapamazsin."); return 0; }
  if (Ust(a, h)) return 0;
  new s[220], n[48], an[48]; Ad(h, n); Ad(a, an);
  hMute[h] = dk; HesapKaydet(h);
  format(s, sizeof s, "[ADMIN] %s, %s adli oyuncuyu %d dk susturdu. Sebep: %s", an, n, dk, sebep);
  SendClientMessageToAll(SARI, s);
  CezaK(a, h, "MUTE", sebep); format(s, sizeof s, "%d dk | %s", dk, sebep); ALog(a, "mute", h, s, k);
  return 1;
}
stock ActJail(a, h, dk, const sebep[], const k[] = "Oyun") {
  if (!IDGecerli(h)) { Hata(a, "Oyuncu karakterde degil."); return 0; }
  if (a == h) { Hata(a, "Kendine islem yapamazsin."); return 0; }
  if (Ust(a, h)) return 0;
  new s[220], n[48], an[48]; Ad(h, n); Ad(a, an);
  hJail[h] = dk; HesapKaydet(h);
  SetPlayerInterior(h, 6); SetPlayerPos(h, 264.6, 77.6, 1001.0);
  format(s, sizeof s, "[ADMIN] %s, %s adli oyuncuyu %d dk hapse gonderdi. Sebep: %s", an, n, dk, sebep);
  SendClientMessageToAll(SARI, s);
  CezaK(a, h, "JAIL", sebep); format(s, sizeof s, "%d dk | %s", dk, sebep); ALog(a, "jail", h, s, k);
  return 1;
}
stock ActWarn(a, h, const sebep[], const k[] = "Oyun") {
  if (a == h) { Hata(a, "Kendine islem yapamazsin."); return 0; }
  if (Ust(a, h)) return 0;
  new s[220], n[48], an[48]; Ad(h, n); Ad(a, an);
  hWarn[h]++; HesapKaydet(h);
  format(s, sizeof s, "[UYARI] %s adli yetkili sana uyari verdi (%d). Sebep: %s", an, hWarn[h], sebep);
  SendClientMessage(h, KIRMIZI, s);
  format(s, sizeof s, "[ADMIN] %s, %s adli oyuncuya uyari verdi (toplam %d).", an, n, hWarn[h]);
  AdminMesaj(s, 2);
  CezaK(a, h, "WARN", sebep); ALog(a, "warn", h, sebep, k);
  return 1;
}
stock ActCoz(a, h, tip, const k[] = "Oyun") {
  if (Ust(a, h)) return 0;
  new s[120], n[48]; Ad(h, n);
  if (tip == 0) { hMute[h] = 0; HesapKaydet(h); SendClientMessage(h, YESIL, "Susturman kaldirildi."); ALog(a, "unmute", h, "-", k); }
  else {
    hJail[h] = 0; HesapKaydet(h);
    if (Aktif[h]) { SetPlayerInterior(h, 0); SetPlayerPos(h, 1554.4, -1675.5, 16.2); }
    SendClientMessage(h, YESIL, "Hapisten cikarildin."); ALog(a, "unjail", h, "-", k);
  }
  format(s, sizeof s, "%s icin islem tamamlandi.", n); Bilgi(a, s);
  return 1;
}
// tip: 0 goto, 1 gethere, 2 heal, 3 revive, 4 freeze, 5 unfreeze, 6 armor, 7 slay
stock ActOyuncu(a, h, tip, const k[] = "Oyun") {
  if (!IDGecerli(h)) { Hata(a, "Oyuncu karakterde degil."); return 0; }
  if ((tip == 1 || tip == 4 || tip == 7) && a != h && Ust(a, h)) return 0;
  new Float:x, Float:y, Float:z, s[120], n[48], nm[12]; Ad(h, n);
  switch (tip) {
    case 0: { GetPlayerPos(h, x, y, z); SetPlayerInterior(a, GetPlayerInterior(h)); SetPlayerVirtualWorld(a, GetPlayerVirtualWorld(h)); SetPlayerPos(a, x + 1.0, y, z); format(nm, sizeof nm, "goto"); }
    case 1: { GetPlayerPos(a, x, y, z); SetPlayerInterior(h, GetPlayerInterior(a)); SetPlayerVirtualWorld(h, GetPlayerVirtualWorld(a)); SetPlayerPos(h, x + 1.0, y, z); SendClientMessage(h, SARI, "Bir yetkili seni yanina isinladi."); format(nm, sizeof nm, "gethere"); }
    case 2: { SetPlayerHealth(h, 100.0); SendClientMessage(h, YESIL, "Bir yetkili seni iyilestirdi."); format(nm, sizeof nm, "heal"); }
    case 3: { SetPlayerHealth(h, 100.0); ClearAnimations(h); SendClientMessage(h, YESIL, "Bir yetkili seni canlandirdi."); format(nm, sizeof nm, "revive"); }
    case 4: { TogglePlayerControllable(h, 0); SendClientMessage(h, SARI, "Bir yetkili seni dondurdu."); format(nm, sizeof nm, "freeze"); }
    case 5: { TogglePlayerControllable(h, 1); SendClientMessage(h, YESIL, "Donman cozuldu."); format(nm, sizeof nm, "unfreeze"); }
    case 6: { SetPlayerArmour(h, 100.0); SendClientMessage(h, YESIL, "Bir yetkili sana zirh verdi."); format(nm, sizeof nm, "armor"); }
    case 7: { SetPlayerHealth(h, 0.0); format(nm, sizeof nm, "slay"); }
    default: return 0;
  }
  ALog(a, nm, h, "-", k);
  format(s, sizeof s, "/%s -> %s: islem uygulandi.", nm, n); Bilgi(a, s);
  return 1;
}
stock SpecKapat(a) { if (aSpec[a]) TogglePlayerSpectating(a, 0); return 1; }
stock ActSpec(a, h, const k[] = "Oyun") {
  if (a == h) { Hata(a, "Kendini izleyemezsin."); return 0; }
  if (Ust(a, h)) return 0;
  if (!aSpec[a]) {
    GetPlayerPos(a, aPos[a][0], aPos[a][1], aPos[a][2]); GetPlayerFacingAngle(a, aPos[a][3]); aInt[a] = GetPlayerInterior(a);
    aSpec[a] = true; TogglePlayerSpectating(a, 1);
  }
  SetPlayerInterior(a, GetPlayerInterior(h)); SetPlayerVirtualWorld(a, GetPlayerVirtualWorld(h));
  if (IsPlayerInAnyVehicle(h)) PlayerSpectateVehicle(a, GetPlayerVehicleID(h)); else PlayerSpectatePlayer(a, h);
  aSpecP[a] = h; ALog(a, "spectate", h, "-", k);
  Bilgi(a, "Izleme basladi. Cikmak icin /specoff");
  return 1;
}
// tip: 0 givemoney, 1 removemoney, 2 setmoney, 3 givebank, 4 removebank, 5 setbank
stock ParaIslem(p, h, tip, m) {
  if (!IDGecerli(h)) return Hata(p, "Oyuncu karakterde degil.");
  if (m < 0 || m > 100000000) return Hata(p, "Miktar 0 - 100000000 arasinda olmali.");
  if (m == 0 && tip != 2 && tip != 5) return Hata(p, "Miktar 0 olamaz.");
  new c = GetPlayerMoney(h), s[120];
  switch (tip) {
    case 0: GivePlayerMoney(h, m);
    case 1: { if (m > c) m = c; GivePlayerMoney(h, -m); }
    case 2: { ResetPlayerMoney(h); GivePlayerMoney(h, m); }
    case 3: cBank[h] += m;
    case 4: { if (m > cBank[h]) m = cBank[h]; cBank[h] -= m; }
    case 5: cBank[h] = m;
    default: return 0;
  }
  KarakterKaydet(h);
  format(s, sizeof s, "%d", m); ALog(p, AParaAd[tip], h, s);
  format(s, sizeof s, "Islem tamam (%s): $%d", AParaAd[tip], m); Bilgi(p, s);
  format(s, sizeof s, "Yetkili hesabinda degisiklik yapti. Nakit: $%d | Banka: $%d", GetPlayerMoney(h), cBank[h]); SendClientMessage(h, SARI, s);
  return 1;
}

// ---------- Arac / sunucu islemleri ----------
stock AracOlustur(p, m) {
  if (m < 400 || m > 611) return Hata(p, "Model 400-611 arasinda olmali.");
  new Float:x, Float:y, Float:z, Float:a, s[60];
  GetPlayerPos(p, x, y, z); GetPlayerFacingAngle(p, a);
  new v = CreateVehicle(m, x, y, z + 1.0, a, -1, -1, -1);
  if (v == INVALID_VEHICLE_ID) return Hata(p, "Arac olusturulamadi (limit).");
  vSahip[v] = 0; LinkVehicleToInterior(v, GetPlayerInterior(p)); SetVehicleVirtualWorld(v, GetPlayerVirtualWorld(p));
  PutPlayerInVehicle(p, v, 0);
  format(s, sizeof s, "model %d", m); ALog(p, "veh", -1, s);
  return 1;
}
// tip: 0 tamir, 1 cevir, 2 sil, 3 bilgi
stock AracIslem(p, tip) {
  new v = GetPlayerVehicleID(p), Float:hp, Float:za, s[120];
  if (!v) return Hata(p, "Bir aracin icinde olmalisin.");
  switch (tip) {
    case 0: { RepairVehicle(v); SetVehicleHealth(v, 1000.0); Bilgi(p, "Arac tamir edildi."); ALog(p, "repair", -1, "-"); }
    case 1: { GetVehicleZAngle(v, za); SetVehicleZAngle(v, za); Bilgi(p, "Arac cevrildi."); ALog(p, "flip", -1, "-"); }
    case 2: { if (vSahip[v]) return Hata(p, "Oyuncu aracini silemezsin."); DestroyVehicle(v); Bilgi(p, "Arac silindi."); ALog(p, "dv", -1, "-"); }
    case 3: { GetVehicleHealth(v, hp); format(s, sizeof s, "Arac ID: %d | Model: %d | Hasar: %.0f/1000 | Oyuncu araci: %s", v, GetVehicleModel(v), hp, vSahip[v] ? "Evet" : "Hayir"); Bilgi(p, s); }
  }
  return 1;
}
stock ADuyuru(p, const msg[]) {
  new s[140];
  format(Duyuru, sizeof Duyuru, "%s", msg);
  format(s, sizeof s, "[DUYURU] %s", msg); SendClientMessageToAll(SARI, s);
  ALog(p, "announce", -1, msg);
  return 1;
}
stock AClear(p) { for (new i = 0; i < 40; i++) SendClientMessageToAll(-1, " "); SendClientMessageToAll(MOR, "[ADMIN] Sohbet temizlendi."); ALog(p, "clearchat", -1, "-"); return 1; }
// tip: 0 healall, 1 reviveall, 2 freezeall, 3 unfreezeall, 4 bringall
stock AToplu(p, tip) {
  new c = 0, Float:x, Float:y, Float:z, s[80];
  GetPlayerPos(p, x, y, z);
  for (new i = 0; i < MAX_PLAYERS; i++) {
    if (!IDGecerli(i) || i == p) continue;
    if ((tip == 2 || tip == 4) && AL(i) > AL(p) && !IsPlayerAdmin(p)) continue;
    switch (tip) {
      case 0: SetPlayerHealth(i, 100.0);
      case 1: { SetPlayerHealth(i, 100.0); ClearAnimations(i); }
      case 2: TogglePlayerControllable(i, 0);
      case 3: TogglePlayerControllable(i, 1);
      case 4: { SetPlayerInterior(i, GetPlayerInterior(p)); SetPlayerVirtualWorld(i, GetPlayerVirtualWorld(p)); SetPlayerPos(i, x + 1.0, y, z); }
    }
    c++;
  }
  format(s, sizeof s, "%d oyuncuya islem uygulandi.", c); Bilgi(p, s);
  ALog(p, AToplamAd[tip], -1, s);
  return 1;
}

// ---------- Log / liste yardimcilari ----------
stock DosyaSon(const yol[], out[], olen, n, const sep[], mc) {
  new r[15][110], c = 0, line[160], i;
  out[0] = 0;
  if (n > 15) n = 15;
  if (!fexist(yol)) return 0;
  new File:h = fopen(yol, io_read);
  if (!h) return 0;
  while (fread(h, line)) {
    Kirp(line);
    for (i = 0; line[i]; i++) { if (line[i] == '|') line[i] = ' '; else if (line[i] == '~') line[i] = '-'; }
    strmid(r[c % 15], line, 0, mc, 110); c++;
  }
  fclose(h);
  new st = (c > n) ? c - n : 0;
  for (i = st; i < c; i++) { strcat(out, r[i % 15], olen); strcat(out, sep, olen); }
  return c;
}
stock LogGoster(p, const yol[], const baslik[]) {
  new s[2000];
  DosyaSon(yol, s, sizeof s, 15, "\n", 105);
  if (!s[0]) strcat(s, "Kayit yok.", sizeof s);
  ShowPlayerDialog(p, D_A_GERI, DIALOG_STYLE_MSGBOX, baslik, s, "Geri", "Kapat");
  return 1;
}
stock CezaSay() {
  aSayi[0] = 0; aSayi[1] = 0; aSayi[2] = 0;
  if (!fexist("duktur/ceza.log")) return 0;
  new line[220], File:h = fopen("duktur/ceza.log", io_read);
  if (!h) return 0;
  while (fread(h, line)) {
    if (strfind(line, "|BAN|") != -1) aSayi[0]++;
    else if (strfind(line, "|MUTE|") != -1) aSayi[1]++;
    else if (strfind(line, "|JAIL|") != -1) aSayi[2]++;
  }
  fclose(h);
  return 1;
}
stock AKomutListe(p, kat) {
  new s[3400], t[130], i, lv, c, L = AL(p);
  for (i = 0; i < sizeof AKm; i++) {
    lv = strval(AKm[i]); c = AKm[i][3] - '0';
    if (lv > L || (kat >= 0 && c != kat)) continue;
    format(t, sizeof t, "{C084FC}[L%d] {FFFFFF}%s\n", lv, AKm[i][5]);
    if (strlen(s) + strlen(t) < sizeof s - 1) strcat(s, t, sizeof s);
  }
  if (!s[0]) strcat(s, "Bu kategoride komut yok.", sizeof s);
  ShowPlayerDialog(p, D_A_GERI, DIALOG_STYLE_MSGBOX, "DUKTUR RP - Komutlar", s, "Geri", "Kapat");
  return 1;
}
stock APInfo(p, h) {
  new s[900], n[48], nk[MAX_PLAYER_NAME], Float:hp, Float:ar, Float:x, Float:y, Float:z, ip[20], t[60];
  GetPlayerName(h, nk, sizeof nk); Ad(h, n); GetPlayerHealth(h, hp); GetPlayerArmour(h, ar); GetPlayerPos(h, x, y, z);
  format(s, sizeof s, "ID: %d\nHesap: %s\nKarakter: %s\nSeviye: %d (%d dk)\nNakit: $%d | Banka: $%d\nMeslek: %s | Birlik: %s (rutbe %d)\nPing: %d ms\nCan: %.0f | Zirh: %.0f\nKonum: %.1f, %.1f, %.1f\nUyari: %d | Mute: %d dk | Jail: %d dk\nYetki: %s (L%d)", h, nk, n, cLevel[h], cMin[h], GetPlayerMoney(h), cBank[h], MeslekAd[cJob[h]], BirlikAd[cFac[h]], cRank[h], GetPlayerPing(h), hp, ar, x, y, z, hWarn[h], hMute[h], hJail[h], AdmAd[AL(h)], AL(h));
  if (AL(p) >= 10) { GetPlayerIp(h, ip, sizeof ip); format(t, sizeof t, "\nIP: %s", ip); strcat(s, t, sizeof s); }
  ShowPlayerDialog(p, D_A_GERI, DIALOG_STYLE_MSGBOX, "DUKTUR RP - Oyuncu Bilgisi", s, "Geri", "Kapat");
  return 1;
}
stock NinciOyuncu(n) { for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && Giris[i]) { if (n == 0) return i; n--; } return -1; }
stock AOyuncuListe(p) {
  new s[2400], t[80], n[48], i;
  for (i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && Giris[i]) {
    Ad(i, n); format(t, sizeof t, "[%d] %s (%d ms) L%d\n", i, n, GetPlayerPing(i), AL(i));
    if (strlen(s) + strlen(t) < sizeof s - 2) strcat(s, t, sizeof s);
  }
  if (!s[0]) strcat(s, "Oyuncu yok.", sizeof s);
  ShowPlayerDialog(p, D_A_OYUNCU, DIALOG_STYLE_LIST, "DUKTUR RP - Oyuncular", s, "Sec", "Geri");
  return 1;
}
stock AIslemGoster(p) { ShowPlayerDialog(p, D_A_ISLEM, DIALOG_STYLE_LIST, "DUKTUR RP - Oyuncu Islemleri", AIslemMetin, "Sec", "Geri"); return 1; }
stock NinciRapor(n) { for (new i = 0; i < MAXRAPOR; i++) if (rOn[i] && rDurum[i] == 0) { if (n == 0) return i; n--; } return -1; }
stock ARaporListe(p) {
  new s[2000], t[180], i;
  for (i = 0; i < MAXRAPOR; i++) if (rOn[i] && rDurum[i] == 0) {
    format(t, sizeof t, "#%d [%s] %s: %s\n", i, RaporTur[rTur[i]], rSahip[i], rMetin[i]);
    if (strlen(s) + strlen(t) < sizeof s - 2) strcat(s, t, sizeof s);
  }
  if (!s[0]) return ShowPlayerDialog(p, D_A_GERI, DIALOG_STYLE_MSGBOX, "Raporlar", "Acik rapor yok.", "Geri", "Kapat");
  ShowPlayerDialog(p, D_A_RAPOR, DIALOG_STYLE_LIST, "DUKTUR RP - Acik Raporlar", s, "Cevapla", "Geri");
  return 1;
}
stock RaporCevap(p, n, const msg[], const on[]) {
  if (n < 0 || n >= MAXRAPOR || !rOn[n]) return Hata(p, "Rapor bulunamadi.");
  format(rCevap[n], 96, "%s%s", on, msg); rDurum[n] = 1; RaporKaydet();
  new o = Buldu(rSahip[n]), s[160];
  if (o >= 0) { format(s, sizeof s, "[RAPOR #%d] Yetkili cevabi: %s", n, rCevap[n]); SendClientMessage(o, MOR, s); }
  format(s, sizeof s, "rapor #%d: %s", n, msg); ALog(p, "replyreport", o, s);
  Bilgi(p, "Rapor cevaplandi.");
  return 1;
}
stock ASunucuBilgi(p) {
  new s[500], oy = 0, ad = 0, rp = 0, up = (GetTickCount() - aBasla) / 1000, i;
  for (i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i)) { oy++; if (Giris[i] && AL(i) > 0) ad++; }
  for (i = 0; i < MAXRAPOR; i++) if (rOn[i] && rDurum[i] == 0) rp++;
  CezaSay();
  format(s, sizeof s, "Oyuncu: %d / %d\nAktif yetkili: %d\nAcik rapor: %d\nUptime: %dg %ds %ddk\nToplam ban: %d | mute: %d | jail: %d\n\nNot: FPS / CPU / RAM verisi SA-MP sunucu tarafinda olculemez, bu yuzden gosterilmez.", oy, GetMaxPlayers(), ad, rp, up / 86400, (up / 3600) % 24, (up / 60) % 60, aSayi[0], aSayi[1], aSayi[2]);
  ShowPlayerDialog(p, D_A_GERI, DIALOG_STYLE_MSGBOX, "DUKTUR RP - Sunucu Bilgisi", s, "Geri", "Kapat");
  return 1;
}
stock ASunucu(p) { ShowPlayerDialog(p, D_A_SUNUCU, DIALOG_STYLE_LIST, "DUKTUR RP - Sunucu", "Sunucu bilgisi\nDuyuru yap\nSohbeti temizle\nTum oyunculari iyilestir\nTum oyunculari canlandir\nTum oyunculari dondur\nTum oyunculari coz", "Sec", "Geri"); return 1; }
stock AAracMenu(p) { ShowPlayerDialog(p, D_A_ARAC, DIALOG_STYLE_LIST, "DUKTUR RP - Arac Yonetimi", "Arac olustur\nAracimi tamir et\nAracimi cevir\nAracimi sil\nArac bilgisi", "Sec", "Geri"); return 1; }

// ---------- Dashboard (textdraw) ----------
stock AdminYenile(p) {
  if (!aAcik[p]) return 0;
  new s[40], i, oy = 0, ad = 0, rp = 0, pg = 0, up = (GetTickCount() - aBasla) / 1000;
  for (i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i)) { oy++; pg += GetPlayerPing(i); if (Giris[i] && AL(i) > 0) ad++; }
  for (i = 0; i < MAXRAPOR; i++) if (rOn[i] && rDurum[i] == 0) rp++;
  format(s, sizeof s, "%d", oy); PlayerTextDrawSetString(p, aTD[p][36], s);
  format(s, sizeof s, "%d", ad); PlayerTextDrawSetString(p, aTD[p][37], s);
  format(s, sizeof s, "%d", rp); PlayerTextDrawSetString(p, aTD[p][38], s);
  format(s, sizeof s, "%d ms", oy ? pg / oy : 0); PlayerTextDrawSetString(p, aTD[p][39], s);
  format(s, sizeof s, "%dg %ds %ddk", up / 86400, (up / 3600) % 24, (up / 60) % 60); PlayerTextDrawSetString(p, aTD[p][40], s);
  format(s, sizeof s, "%d", aSayi[0]); PlayerTextDrawSetString(p, aTD[p][41], s);
  format(s, sizeof s, "%d", aSayi[1]); PlayerTextDrawSetString(p, aTD[p][42], s);
  format(s, sizeof s, "%d", aSayi[2]); PlayerTextDrawSetString(p, aTD[p][43], s);
  return 1;
}
stock AdminKapat(p) {
  if (!aAcik[p]) return 0;
  aAcik[p] = false;
  for (new i = 0; i < 47; i++) PlayerTextDrawDestroy(p, aTD[p][i]);
  CancelSelectTextDraw(p);
  return 1;
}
stock AdminPanel(p) {
  if (AL(p) < 2) return Hata(p, "Admin paneline erisimin yok.");
  if (aAcik[p]) return 1;
  new i, s[96], ls[420], Float:fx, Float:fy;
  CezaSay();
  aAcik[p] = true;
  aTD[p][0] = TDResim(p, 92.0, 70.0, 456.0, 300.0, "LD_SPAC:white", 0x0A0612F0, 0);
  aTD[p][1] = TDResim(p, 92.0, 70.0, 456.0, 24.0, "LD_SPAC:white", 0x7C3AEDFF, 0);
  aTD[p][2] = TDYazi(p, 100.0, 73.0, "DUKTUR RP - ADMIN CONTROL CENTER V3.0", 0.26, 1.4, 1, 1);
  format(s, sizeof s, "%s  L%d", AdmAd[AL(p)], AL(p));
  aTD[p][3] = TDYazi(p, 540.0, 75.0, s, 0.2, 1.1, 1, 3);
  PlayerTextDrawColor(p, aTD[p][3], 0xE9D5FFFF);
  for (i = 0; i < 8; i++) {
    fy = 102.0 + float(i) * 33.0;
    aTD[p][4 + i] = TDResim(p, 100.0, fy, 104.0, 28.0, "LD_SPAC:white", (i == 7) ? 0x7F1D1DFF : 0x3B1A78FF, 1);
    aTD[p][12 + i] = TDYazi(p, 152.0, fy + 8.0, ABtn[i], 0.2, 1.1, 1, 2);
  }
  for (i = 0; i < 8; i++) {
    fx = 214.0 + float(i % 4) * 82.0; fy = 102.0 + float(i / 4) * 66.0;
    aTD[p][20 + i] = TDResim(p, fx, fy, 78.0, 60.0, "LD_SPAC:white", 0x1E1040FF, 0);
    aTD[p][28 + i] = TDYazi(p, fx + 39.0, fy + 6.0, ATileAd[i], 0.15, 0.9, 1, 2);
    PlayerTextDrawColor(p, aTD[p][28 + i], 0xA1A1AAFF);
    aTD[p][36 + i] = TDYazi(p, fx + 39.0, fy + 24.0, "0", 0.3, 1.5, 1, 2);
    PlayerTextDrawColor(p, aTD[p][36 + i], 0xC084FCFF);
  }
  aTD[p][44] = TDResim(p, 214.0, 236.0, 326.0, 128.0, "LD_SPAC:white", 0x150B2EFF, 0);
  aTD[p][45] = TDYazi(p, 222.0, 240.0, "SON ADMIN ISLEMLERI", 0.17, 1.0, 1, 1);
  PlayerTextDrawColor(p, aTD[p][45], 0xC084FCFF);
  DosyaSon("duktur/adminlog.log", ls, sizeof ls, 7, "~n~", 62);
  if (!ls[0]) format(ls, sizeof ls, "Kayit yok.");
  aTD[p][46] = TDYazi(p, 222.0, 253.0, ls, 0.15, 0.95, 1, 1);
  PlayerTextDrawTextSize(p, aTD[p][46], 535.0, 0.0);
  PlayerTextDrawColor(p, aTD[p][46], 0xD4D4D8FF);
  for (i = 0; i < 47; i++) PlayerTextDrawShow(p, aTD[p][i]);
  AdminYenile(p);
  SelectTextDraw(p, 0xC084FCFF);
  return 1;
}
stock AdminTikla(p, PlayerText:t) {
  for (new i = 0; i < 8; i++) if (t == aTD[p][4 + i]) {
    AdminKapat(p);
    switch (i) {
      case 0: AOyuncuListe(p);
      case 1: AKomutListe(p, -1);
      case 2: ARaporListe(p);
      case 3: ASunucu(p);
      case 4: { if (AL(p) < 5) { Hata(p, "Arac yonetimi icin Level 5 gerekir."); AdminPanel(p); } else AAracMenu(p); }
      case 5: AKomutListe(p, 3);
      case 6: { if (AL(p) < 7) { Hata(p, "Loglar icin Level 7 gerekir."); AdminPanel(p); } else LogGoster(p, "duktur/adminlog.log", "DUKTUR RP - Admin Loglari"); }
    }
    return 1;
  }
  return 0;
}
public AdminSaniye() {
  aSy++;
  for (new i = 0; i < MAX_PLAYERS; i++) {
    if (!IsPlayerConnected(i)) continue;
    if (aGod[i] && Aktif[i]) SetPlayerHealth(i, 100.0);
    if (aAcik[i] && aSy % 3 == 0) AdminYenile(i);
  }
  return 1;
}

// ---------- Panel dialoglari ----------
stock AdminDialog(p, dialogid, response, listitem, const inputtext[]) {
  new h, s[200], idx = 0, a[24], t[96], dk = 0, iz;
  switch (dialogid) {
    case D_A_GERI: { if (response) AdminPanel(p); return 1; }
    case D_A_OYUNCU: {
      if (!response) { AdminPanel(p); return 1; }
      h = NinciOyuncu(listitem);
      if (h < 0) return Hata(p, "Oyuncu bulunamadi.");
      aHedef[p] = h; AIslemGoster(p); return 1;
    }
    case D_A_ISLEM: {
      if (!response) { AOyuncuListe(p); return 1; }
      h = aHedef[p];
      if (h < 0 || h >= MAX_PLAYERS || !IsPlayerConnected(h) || !Giris[h]) return Hata(p, "Oyuncu artik sunucuda degil.");
      if (listitem < 0 || listitem > 14) return 1;
      if (AL(p) < AIsLv[listitem]) { Hata(p, "Bu islem icin yetkin yetersiz."); AIslemGoster(p); return 1; }
      switch (listitem) {
        case 0: { APInfo(p, h); return 1; }
        case 1: ActOyuncu(p, h, 0, "Panel");
        case 2: ActOyuncu(p, h, 1, "Panel");
        case 3: ActOyuncu(p, h, 2, "Panel");
        case 4: ActOyuncu(p, h, 3, "Panel");
        case 5: ActOyuncu(p, h, 4, "Panel");
        case 6: ActOyuncu(p, h, 5, "Panel");
        case 7: { ActSpec(p, h, "Panel"); return 1; }
        case 10: ActCoz(p, h, 0, "Panel");
        case 12: ActCoz(p, h, 1, "Panel");
        case 8, 9, 11, 13, 14: {
          aIslem[p] = listitem;
          if (listitem == 8 || listitem == 13) format(s, sizeof s, "Sebep yaz:");
          else if (listitem == 14) format(s, sizeof s, "Sure (dakika, 0 = kalici) ve sebep:\nOrnek: 0 Hile");
          else format(s, sizeof s, "Sure (dakika) ve sebep:\nOrnek: 30 RDM");
          ShowPlayerDialog(p, D_A_SEBEP, DIALOG_STYLE_INPUT, "DUKTUR RP - Islem", s, "Uygula", "Iptal");
          return 1;
        }
      }
      AIslemGoster(p); return 1;
    }
    case D_A_SEBEP: {
      if (!response) { AIslemGoster(p); return 1; }
      h = aHedef[p]; iz = aIslem[p];
      if (h < 0 || h >= MAX_PLAYERS || !IsPlayerConnected(h) || !Giris[h]) return Hata(p, "Oyuncu artik sunucuda degil.");
      if (iz == 8 || iz == 13) Kalan(inputtext, idx, t);
      else { Tok(inputtext, idx, a, sizeof a); Kalan(inputtext, idx, t); dk = strval(a); }
      Sebep(t);
      switch (iz) {
        case 8: ActWarn(p, h, t, "Panel");
        case 9: { if (dk < 1 || dk > 1440) return Hata(p, "Sure 1-1440 dk olmali."); ActMute(p, h, dk, t, "Panel"); }
        case 11: { if (dk < 1 || dk > 720) return Hata(p, "Sure 1-720 dk olmali."); ActJail(p, h, dk, t, "Panel"); }
        case 13: ActKick(p, h, t, "Panel");
        case 14: {
          if (dk < 0 || dk > 43200) return Hata(p, "Sure 0-43200 dk olmali.");
          if (AL(p) < ((dk > 0) ? 6 : 7)) return Hata(p, "Kalici ban icin Level 7 gerekir.");
          ActBan(p, h, dk, t, "Panel");
        }
      }
      return 1;
    }
    case D_A_RAPOR: {
      if (!response) { AdminPanel(p); return 1; }
      h = NinciRapor(listitem);
      if (h < 0) return Hata(p, "Rapor bulunamadi.");
      aRap[p] = h;
      format(s, sizeof s, "Rapor #%d: %s\n\nCevabini yaz:", h, rMetin[h]);
      ShowPlayerDialog(p, D_A_RCEVAP, DIALOG_STYLE_INPUT, "DUKTUR RP - Rapor Cevapla", s, "Gonder", "Iptal");
      return 1;
    }
    case D_A_RCEVAP: {
      if (!response) { ARaporListe(p); return 1; }
      Kalan(inputtext, idx, t);
      if (!t[0]) return Hata(p, "Cevap bos olamaz.");
      RaporCevap(p, aRap[p], t, "");
      return 1;
    }
    case D_A_SUNUCU: {
      if (!response) { AdminPanel(p); return 1; }
      if (listitem < 0 || listitem > 6) return 1;
      if (AL(p) < ASunLv[listitem]) { Hata(p, "Bu islem icin yetkin yetersiz."); ASunucu(p); return 1; }
      switch (listitem) {
        case 0: ASunucuBilgi(p);
        case 1: ShowPlayerDialog(p, D_A_DUYURU, DIALOG_STYLE_INPUT, "DUKTUR RP - Duyuru", "Duyuru metnini yaz:", "Yayinla", "Iptal");
        case 2: { AClear(p); ASunucu(p); }
        case 3: { AToplu(p, 0); ASunucu(p); }
        case 4: { AToplu(p, 1); ASunucu(p); }
        case 5: { AToplu(p, 2); ASunucu(p); }
        case 6: { AToplu(p, 3); ASunucu(p); }
      }
      return 1;
    }
    case D_A_DUYURU: {
      if (!response || AL(p) < 5) return 1;
      Kalan(inputtext, idx, t);
      if (!t[0]) return Hata(p, "Duyuru bos olamaz.");
      ADuyuru(p, t); return 1;
    }
    case D_A_ARAC: {
      if (!response) { AdminPanel(p); return 1; }
      if (AL(p) < 5) return Hata(p, "Arac yonetimi icin Level 5 gerekir.");
      if (listitem == 0) { ShowPlayerDialog(p, D_A_VEH, DIALOG_STYLE_INPUT, "DUKTUR RP - Arac Olustur", "Model ID (400-611):", "Olustur", "Iptal"); return 1; }
      AracIslem(p, listitem - 1); AAracMenu(p); return 1;
    }
    case D_A_VEH: {
      if (!response || AL(p) < 5) return 1;
      AracOlustur(p, strval(inputtext)); return 1;
    }
  }
  return 0;
}

// ---------- Slash komutlari ----------
stock AdminKomut(playerid, cmdtext[]) {
  new idx = 0, cmd[24], a1[40], a2[40], t[96], s[400], i, h, dk, n[48], Float:fx, Float:fy, Float:fz;
  Tok(cmdtext, idx, cmd, sizeof cmd);
  if (cmd[0] != '/' || !Aktif[playerid]) return 0;
  ALIAS("/adminmenu", "/admin"); ALIAS("/tp", "/goto"); ALIAS("/bring", "/gethere"); ALIAS("/tphere", "/gethere");
  ALIAS("/spectate", "/spec"); ALIAS("/car", "/veh"); ALIAS("/delveh", "/dv"); ALIAS("/fix", "/repair");
  ALIAS("/adminchat", "/a"); ALIAS("/stafflist", "/admins"); ALIAS("/serverstatus", "/serverinfo"); ALIAS("/serverplayers", "/players");
  ALIAS("/announce", "/ann"); ALIAS("/setgroup", "/setadmin"); ALIAS("/gotoCoords", "/gotocoords");

  if (!strcmp(cmd, "/admins", true)) {
    s[0] = 0;
    for (i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && Giris[i] && AL(i) > 0) { GetPlayerName(i, n, sizeof n); format(t, sizeof t, "[L%d] %s - %s\n", AL(i), n, AdmAd[AL(i)]); strcat(s, t, sizeof s); }
    if (!s[0]) strcat(s, "Cevrimici yetkili yok.", sizeof s);
    ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "Cevrimici Yetkililer", s, "Kapat", "");
    return 1;
  }
  ADM("/admin", 2) { AdminPanel(playerid); return 1; }
  ADM("/ahelp", 2) { AKomutListe(playerid, -1); return 1; }
  ADM("/a", 2) {
    Kalan(cmdtext, idx, t); if (!t[0]) return Hata(playerid, "Kullanim: /a [mesaj]");
    GetPlayerName(playerid, n, sizeof n); format(s, sizeof s, "[ADMIN-CHAT] %s (L%d): %s", n, AL(playerid), t); AdminMesaj(s, 2); return 1;
  }
  ADM("/ann", 5) { Kalan(cmdtext, idx, t); if (!t[0]) return Hata(playerid, "Kullanim: /ann [mesaj]"); ADuyuru(playerid, t); return 1; }
  ADM("/clearchat", 5) { AClear(playerid); return 1; }
  ADM("/serverinfo", 4) { ASunucuBilgi(playerid); return 1; }
  ADM("/adminlog", 7) { LogGoster(playerid, "duktur/adminlog.log", "DUKTUR RP - Admin Loglari"); return 1; }
  ADM("/serverlogs", 7) { LogGoster(playerid, "duktur/ceza.log", "DUKTUR RP - Ceza Loglari"); return 1; }
  ADM("/coords", 4) { GetPlayerPos(playerid, fx, fy, fz); format(s, sizeof s, "Koordinat: %.2f, %.2f, %.2f | Interior: %d | VW: %d", fx, fy, fz, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid)); Bilgi(playerid, s); return 1; }
  ADM("/gotocoords", 5) {
    Tok(cmdtext, idx, a1, sizeof a1); Tok(cmdtext, idx, a2, sizeof a2); Tok(cmdtext, idx, t, sizeof t);
    if (!a1[0] || !a2[0] || !t[0]) return Hata(playerid, "Kullanim: /gotocoords [x] [y] [z]");
    SetPlayerPos(playerid, floatstr(a1), floatstr(a2), floatstr(t)); ALog(playerid, "gotocoords", -1, cmdtext); return 1;
  }
  ADM("/god", 6) {
    aGod[playerid] = !aGod[playerid];
    if (aGod[playerid]) { ALog(playerid, "god", -1, "acik"); return Bilgi(playerid, "God modu ACIK."); }
    ALog(playerid, "god", -1, "kapali"); return Bilgi(playerid, "God modu KAPALI.");
  }

  ADM("/fly", 6) {
    if (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK) { SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE); ALog(playerid, "fly", -1, "kapali"); return Bilgi(playerid, "Jetpack KAPALI."); }
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK); ALog(playerid, "fly", -1, "acik"); return Bilgi(playerid, "Jetpack verildi. Tekrar /fly yazarsan kapanir.");
  }
  ADM("/players", 4) { AOyuncuListe(playerid); return 1; }
  ADM("/playerinfo", 4) { HEDEF("Kullanim: /playerinfo [id]"); APInfo(playerid, h); return 1; }
  ADM("/goto", 4) { HEDEF("Kullanim: /goto [id]"); ActOyuncu(playerid, h, 0); return 1; }
  ADM("/gethere", 4) { HEDEF("Kullanim: /gethere [id]"); ActOyuncu(playerid, h, 1); return 1; }
  ADM("/heal", 4) { HEDEF("Kullanim: /heal [id]"); ActOyuncu(playerid, h, 2); return 1; }
  ADM("/revive", 4) { HEDEF("Kullanim: /revive [id]"); ActOyuncu(playerid, h, 3); return 1; }
  ADM("/freeze", 4) { HEDEF("Kullanim: /freeze [id]"); ActOyuncu(playerid, h, 4); return 1; }
  ADM("/unfreeze", 4) { HEDEF("Kullanim: /unfreeze [id]"); ActOyuncu(playerid, h, 5); return 1; }
  ADM("/armor", 4) { HEDEF("Kullanim: /armor [id]"); ActOyuncu(playerid, h, 6); return 1; }
  ADM("/slay", 5) { HEDEF("Kullanim: /slay [id]"); ActOyuncu(playerid, h, 7); return 1; }
  ADM("/spec", 4) { HEDEF("Kullanim: /spec [id]"); ActSpec(playerid, h); return 1; }
  ADM("/specoff", 4) { if (!aSpec[playerid]) return Hata(playerid, "Izlemiyorsun."); SpecKapat(playerid); ALog(playerid, "specoff", -1, "-"); return 1; }
  ADM("/kick", 4) { HEDEF("Kullanim: /kick [id] [sebep]"); Kalan(cmdtext, idx, t); Sebep(t); ActKick(playerid, h, t); return 1; }
  ADM("/warn", 4) { HEDEF("Kullanim: /warn [id] [sebep]"); Kalan(cmdtext, idx, t); Sebep(t); ActWarn(playerid, h, t); return 1; }
  ADM("/mute", 4) {
    HEDEF("Kullanim: /mute [id] [dk] [sebep]"); Tok(cmdtext, idx, a2, sizeof a2); dk = strval(a2);
    if (dk < 1 || dk > 1440) return Hata(playerid, "Sure 1-1440 dk olmali.");
    Kalan(cmdtext, idx, t); Sebep(t); ActMute(playerid, h, dk, t); return 1;
  }
  ADM("/unmute", 4) { HEDEF("Kullanim: /unmute [id]"); ActCoz(playerid, h, 0); return 1; }
  ADM("/jail", 5) {
    HEDEF("Kullanim: /jail [id] [dk] [sebep]"); Tok(cmdtext, idx, a2, sizeof a2); dk = strval(a2);
    if (dk < 1 || dk > 720) return Hata(playerid, "Sure 1-720 dk olmali.");
    Kalan(cmdtext, idx, t); Sebep(t); ActJail(playerid, h, dk, t); return 1;
  }
  ADM("/unjail", 5) { HEDEF("Kullanim: /unjail [id]"); ActCoz(playerid, h, 1); return 1; }
  ADM("/tempban", 6) {
    HEDEF("Kullanim: /tempban [id] [dk] [sebep]"); Tok(cmdtext, idx, a2, sizeof a2); dk = strval(a2);
    if (dk < 1 || dk > 43200) return Hata(playerid, "Sure 1-43200 dk olmali.");
    Kalan(cmdtext, idx, t); Sebep(t); ActBan(playerid, h, dk, t); return 1;
  }
  ADM("/ban", 7) { HEDEF("Kullanim: /ban [id] [sebep]"); Kalan(cmdtext, idx, t); Sebep(t); ActBan(playerid, h, 0, t); return 1; }
  ADM("/unban", 7) {
    Tok(cmdtext, idx, a1, sizeof a1);
    if (!a1[0]) return Hata(playerid, "Kullanim: /unban [hesap_nick]");
    i = UnbanYap(a1);
    if (i < 0) return Hata(playerid, "Hesap bulunamadi.");
    if (i == 0) return Hata(playerid, "Bu hesap banli degil.");
    GetPlayerName(playerid, n, sizeof n); CezaLog(a1, "UNBAN", n, "-"); ALog(playerid, "unban", -1, a1);
    format(s, sizeof s, "[ADMIN] %s hesabinin yasagi kaldirildi.", a1); AdminMesaj(s, 2); return 1;
  }
  ADM("/healall", 7) { AToplu(playerid, 0); return 1; }
  ADM("/reviveall", 7) { AToplu(playerid, 1); return 1; }
  ADM("/freezeall", 7) { AToplu(playerid, 2); return 1; }
  ADM("/unfreezeall", 7) { AToplu(playerid, 3); return 1; }
  ADM("/bringall", 10) { AToplu(playerid, 4); return 1; }

  ADM("/veh", 5) { Tok(cmdtext, idx, a1, sizeof a1); if (!a1[0]) return Hata(playerid, "Kullanim: /veh [model 400-611]"); AracOlustur(playerid, strval(a1)); return 1; }
  ADM("/dv", 5) { AracIslem(playerid, 2); return 1; }
  ADM("/repair", 5) { AracIslem(playerid, 0); return 1; }
  ADM("/flip", 5) { AracIslem(playerid, 1); return 1; }
  ADM("/vehicleinfo", 5) { AracIslem(playerid, 3); return 1; }
  ADM("/setplate", 7) {
    Tok(cmdtext, idx, a1, sizeof a1); if (!a1[0]) return Hata(playerid, "Kullanim: /setplate [plaka]");
    i = GetPlayerVehicleID(playerid); if (!i) return Hata(playerid, "Bir aracin icinde olmalisin.");
    SetVehicleNumberPlate(i, a1); ALog(playerid, "setplate", -1, a1); return Bilgi(playerid, "Plaka ayarlandi (arac yeniden dogunca gorunur).");
  }

  ADM("/givemoney", 8) { HEDEF("Kullanim: /givemoney [id] [miktar]"); Tok(cmdtext, idx, a2, sizeof a2); ParaIslem(playerid, h, 0, strval(a2)); return 1; }
  ADM("/removemoney", 8) { HEDEF("Kullanim: /removemoney [id] [miktar]"); Tok(cmdtext, idx, a2, sizeof a2); ParaIslem(playerid, h, 1, strval(a2)); return 1; }
  ADM("/setmoney", 8) { HEDEF("Kullanim: /setmoney [id] [miktar]"); Tok(cmdtext, idx, a2, sizeof a2); ParaIslem(playerid, h, 2, strval(a2)); return 1; }
  ADM("/givebank", 8) { HEDEF("Kullanim: /givebank [id] [miktar]"); Tok(cmdtext, idx, a2, sizeof a2); ParaIslem(playerid, h, 3, strval(a2)); return 1; }
  ADM("/removebank", 8) { HEDEF("Kullanim: /removebank [id] [miktar]"); Tok(cmdtext, idx, a2, sizeof a2); ParaIslem(playerid, h, 4, strval(a2)); return 1; }
  ADM("/setbank", 8) { HEDEF("Kullanim: /setbank [id] [miktar]"); Tok(cmdtext, idx, a2, sizeof a2); ParaIslem(playerid, h, 5, strval(a2)); return 1; }
  ADM("/giveitem", 6) {
    HEDEF("Kullanim: /giveitem [id] [esya 0-7] [adet]"); Tok(cmdtext, idx, a2, sizeof a2); Tok(cmdtext, idx, t, sizeof t);
    i = strval(a2); dk = strval(t);
    if (!IDGecerli(h)) return Hata(playerid, "Oyuncu karakterde degil.");
    if (i < 0 || i > 7 || dk < 1 || dk > 50) return Hata(playerid, "Esya 0-7, adet 1-50 olmali.");
    if (!Env_Ekle(h, i, dk)) return Hata(playerid, "Oyuncunun envanteri dolu.");
    format(s, sizeof s, "%s x%d", EsyaAd[i], dk); ALog(playerid, "giveitem", h, s);
    format(t, sizeof t, "Bir yetkili sana esya verdi: %s", s); SendClientMessage(h, SARI, t); return Bilgi(playerid, "Esya verildi.");
  }
  ADM("/clearinventory", 7) {
    HEDEF("Kullanim: /clearinventory [id]"); if (!IDGecerli(h)) return Hata(playerid, "Oyuncu karakterde degil.");
    for (i = 0; i < 8; i++) cInv[h][i] = 0; ALog(playerid, "clearinventory", h, "-"); KarakterKaydet(h); return Bilgi(playerid, "Envanter temizlendi.");
  }

  ADM("/setskin", 6) {
    HEDEF("Kullanim: /setskin [id] [model]"); Tok(cmdtext, idx, a2, sizeof a2); dk = strval(a2);
    if (!IDGecerli(h)) return Hata(playerid, "Oyuncu karakterde degil.");
    if (dk < 0 || dk > 311) return Hata(playerid, "Skin 0-311 olmali.");
    cSkin[h] = dk; SetPlayerSkin(h, dk); KarakterKaydet(h); ALog(playerid, "setskin", h, a2); return Bilgi(playerid, "Skin degistirildi.");
  }
  ADM("/setjob", 7) {
    HEDEF("Kullanim: /setjob [id] [0-11]"); Tok(cmdtext, idx, a2, sizeof a2); dk = strval(a2);
    if (!IDGecerli(h)) return Hata(playerid, "Oyuncu karakterde degil.");
    if (dk < 0 || dk > 11) return Hata(playerid, "Meslek 0-11 olmali.");
    cJob[h] = dk; KarakterKaydet(h); ALog(playerid, "setjob", h, MeslekAd[dk]); format(s, sizeof s, "Yeni meslek: %s", MeslekAd[dk]); SendClientMessage(h, SARI, s); return Bilgi(playerid, "Meslek ayarlandi.");
  }
  ADM("/removejob", 7) { HEDEF("Kullanim: /removejob [id]"); if (!IDGecerli(h)) return Hata(playerid, "Oyuncu karakterde degil."); cJob[h] = 0; KarakterKaydet(h); ALog(playerid, "removejob", h, "-"); return Bilgi(playerid, "Meslek alindi."); }
  ADM("/setgang", 7) {
    HEDEF("Kullanim: /setgang [id] [birlik 0-5] [rutbe]"); Tok(cmdtext, idx, a2, sizeof a2); Tok(cmdtext, idx, t, sizeof t);
    dk = strval(a2); i = strval(t);
    if (!IDGecerli(h)) return Hata(playerid, "Oyuncu karakterde degil.");
    if (dk < 0 || dk > 5 || i < 0 || i > 10) return Hata(playerid, "Birlik 0-5, rutbe 0-10 olmali.");
    cFac[h] = dk; cRank[h] = i; KarakterKaydet(h); ALog(playerid, "setgang", h, BirlikAd[dk]); return Bilgi(playerid, "Birlik ayarlandi.");
  }
  ADM("/removegang", 7) { HEDEF("Kullanim: /removegang [id]"); if (!IDGecerli(h)) return Hata(playerid, "Oyuncu karakterde degil."); cFac[h] = 0; cRank[h] = 0; KarakterKaydet(h); ALog(playerid, "removegang", h, "-"); return Bilgi(playerid, "Birlikten cikarildi."); }
  ADM("/setadmin", 14) {
    HEDEF("Kullanim: /setadmin [id] [0,2,4-15]"); Tok(cmdtext, idx, a2, sizeof a2); dk = strval(a2);
    if (dk < 0 || dk > 15 || dk == 1 || dk == 3) return Hata(playerid, "Gecerli seviyeler: 0, 2, 4-15.");
    if (dk > AL(playerid)) return Hata(playerid, "Kendi seviyenden yuksek rol veremezsin.");
    if (!IsPlayerAdmin(playerid) && AL(h) > AL(playerid)) return Hata(playerid, "Senden yuksek yetkilinin rolune mudahale edemezsin.");
    if (h == playerid && !IsPlayerAdmin(playerid)) return Hata(playerid, "Kendi rolunu degistiremezsin.");
    hAdm[h] = dk; HesapKaydet(h);
    format(s, sizeof s, "Yetkin degistirildi: %s (L%d)", AdmAd[dk], dk); SendClientMessage(h, SARI, s);
    GetPlayerName(h, n, sizeof n); format(s, sizeof s, "[ADMIN] %s adli oyuncunun rolu: %s (L%d)", n, AdmAd[dk], dk); AdminMesaj(s, 2);
    ALog(playerid, "setadmin", h, AdmAd[dk]); return 1;
  }

  ADM("/weather", 7) { Tok(cmdtext, idx, a1, sizeof a1); if (!a1[0]) return Hata(playerid, "Kullanim: /weather [0-45]"); dk = strval(a1); if (dk < 0 || dk > 45) return Hata(playerid, "Hava 0-45 olmali."); SetWeather(dk); ALog(playerid, "weather", -1, a1); return Bilgi(playerid, "Hava durumu degisti."); }
  ADM("/time", 7) { Tok(cmdtext, idx, a1, sizeof a1); if (!a1[0]) return Hata(playerid, "Kullanim: /time [0-23]"); dk = strval(a1); if (dk < 0 || dk > 23) return Hata(playerid, "Saat 0-23 olmali."); SetWorldTime(dk); ALog(playerid, "time", -1, a1); return Bilgi(playerid, "Saat degisti."); }
  ADM("/serverrestart", 10) {
    Tok(cmdtext, idx, a1, sizeof a1); dk = strval(a1);
    if (dk < 5 || dk > 600) return Hata(playerid, "Kullanim: /serverrestart [5-600 sn]");
    format(s, sizeof s, "[SUNUCU] %d saniye icinde yeniden baslatilacak! Verileriniz kaydedilir.", dk); SendClientMessageToAll(KIRMIZI, s);
    SetTimer("GMXYap", dk * 1000, false); ALog(playerid, "serverrestart", -1, a1); return 1;
  }

  ADM("/reports", 4) {
    s[0] = 0;
    for (i = 0; i < MAXRAPOR; i++) if (rOn[i]) { format(t, sizeof t, "#%d [%s] %s - %s\n", i, rDurum[i] ? "Cevaplandi" : "ACIK", rSahip[i], rMetin[i]); if (strlen(s) + strlen(t) < sizeof s - 2) strcat(s, t, sizeof s); }
    if (!s[0]) strcat(s, "Rapor yok.", sizeof s);
    ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "Raporlar", s, "Kapat", ""); return 1;
  }
  ADM("/reportinfo", 4) {
    Tok(cmdtext, idx, a1, sizeof a1); dk = strval(a1);
    if (!a1[0] || dk < 0 || dk >= MAXRAPOR || !rOn[dk]) return Hata(playerid, "Kullanim: /reportinfo [no] (rapor bulunamadi)");
    format(s, sizeof s, "Rapor #%d\nTur: %s\nSahip: %s\nDurum: %s\nMetin: %s\nCevap: %s", dk, RaporTur[rTur[dk]], rSahip[dk], rDurum[dk] ? "Cevaplandi" : "Acik", rMetin[dk], rCevap[dk][0] ? rCevap[dk] : "-");
    ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "Rapor Bilgisi", s, "Kapat", ""); return 1;
  }
  ADM("/acceptreport", 4) {
    Tok(cmdtext, idx, a1, sizeof a1); dk = strval(a1);
    if (!a1[0] || dk < 0 || dk >= MAXRAPOR || !rOn[dk]) return Hata(playerid, "Kullanim: /acceptreport [no]");
    i = Buldu(rSahip[dk]); if (i >= 0) SendClientMessage(i, MOR, "[RAPOR] Raporun bir yetkili tarafindan kabul edildi, ilgileniliyor.");
    ALog(playerid, "acceptreport", i, a1); return Bilgi(playerid, "Rapor kabul edildi, sahibine bildirildi.");
  }
  ADM("/replyreport", 4) {
    Tok(cmdtext, idx, a1, sizeof a1); Kalan(cmdtext, idx, t);
    if (!a1[0] || !t[0]) return Hata(playerid, "Kullanim: /replyreport [no] [mesaj]");
    RaporCevap(playerid, strval(a1), t, ""); return 1;
  }
  ADM("/denyreport", 4) {
    Tok(cmdtext, idx, a1, sizeof a1); Kalan(cmdtext, idx, t);
    if (!a1[0]) return Hata(playerid, "Kullanim: /denyreport [no] [mesaj]");
    if (!t[0]) format(t, sizeof t, "Gecerli sebep bulunamadi.");
    RaporCevap(playerid, strval(a1), t, "REDDEDILDI: "); return 1;
  }
  ADM("/closereport", 4) {
    Tok(cmdtext, idx, a1, sizeof a1); dk = strval(a1);
    if (!a1[0] || dk < 0 || dk >= MAXRAPOR || !rOn[dk]) return Hata(playerid, "Kullanim: /closereport [no]");
    rOn[dk] = 0; RaporKaydet(); ALog(playerid, "closereport", -1, a1); return Bilgi(playerid, "Rapor kapatildi.");
  }
  return 0;
}

// ---------- Callbacklar ----------
main() {}

public OnGameModeInit() {
  SetGameModeText("DUKTUR RP");
  AddPlayerClass(0, 1759.0, -1898.1, 13.6, 0.0, 0, 0, 0, 0, 0, 0);
  DisableInteriorEnterExits(); UsePlayerPedAnims(); EnableStuntBonusForAll(0);
  MulkYukle(); RaporYukle(); BasvuruYukle();
  SetTimer("Dakika", 60000, true); SetTimer("AdminSaniye", 1000, true); aBasla = GetTickCount();
  Etkinlik[0] = 0; Duyuru[0] = 0;
  return 1;
}
public OnGameModeExit() { for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i)) { KarakterKaydet(i); if (Giris[i]) HesapKaydet(i); } return 1; }

public OnPlayerConnect(playerid) {
  Giris[playerid] = false; Aktif[playerid] = false; Deneme[playerid] = 0; Davet[playerid] = 0; Aranan[playerid] = 0; Konusuyor[playerid] = 0; Katildi[playerid] = false;
  hSifre[playerid] = 0; hAdm[playerid] = 0; hBan[playerid] = 0; hWarn[playerid] = 0; hMute[playerid] = 0; hJail[playerid] = 0; hBanSebep[playerid][0] = 0; hBanEnd[playerid] = 0;
  aAcik[playerid] = false; aSpec[playerid] = false; aGod[playerid] = false; aHedef[playerid] = -1; aSon[playerid] = 0;
  for (new i = 0; i < 4; i++) hSlot[playerid][i][0] = 0;
  KarakterSifirla(playerid);
  sAcik[playerid] = false; sSecim[playerid] = 0;
  TogglePlayerSpectating(playerid, 1);
  SetPlayerCameraPos(playerid, 1760.0, -1910.0, 40.0); SetPlayerCameraLookAt(playerid, 1759.0, -1898.0, 13.5);
  SendClientMessage(playerid, MOR, "DUKTUR RP - YOUR LIFE, YOUR STORY, YOUR ROLEPLAY.");
  if (HesapYukle(playerid)) {
    if (hBan[playerid] && hBanEnd[playerid] != 0 && hBanEnd[playerid] <= gettime()) { hBan[playerid] = 0; hBanEnd[playerid] = 0; HesapKaydet(playerid); }
    if (hBan[playerid]) { new s[100]; format(s, sizeof s, "Hesabin yasakli. Sebep: %s", hBanSebep[playerid]); SendClientMessage(playerid, KIRMIZI, s); SetTimerEx("KickGec", 800, false, "i", playerid); return 1; }
    ShowPlayerDialog(playerid, D_GIRIS, DIALOG_STYLE_PASSWORD, "DUKTUR RP - Giris", "Hesabin kayitli. Sifreni gir:", "Giris", "Cikis");
  } else ShowPlayerDialog(playerid, D_KAYIT, DIALOG_STYLE_PASSWORD, "DUKTUR RP - Kayit", "Hesabin yok. Bir sifre belirle (en az 6 karakter):", "Kayit ol", "Cikis");
  return 1;
}
public OnPlayerDisconnect(playerid, reason) {
  aAcik[playerid] = false; aGod[playerid] = false;
  for (new q = 0; q < MAX_PLAYERS; q++) if (q != playerid && IsPlayerConnected(q) && aSpec[q] && aSpecP[q] == playerid) SpecKapat(q);
  sAcik[playerid] = false;
  if (Aktif[playerid]) { KarakterKaydet(playerid); for (new i = 0; i < 3; i++) AracPark(playerid, i); }
  if (Giris[playerid]) HesapKaydet(playerid);
  Giris[playerid] = false; Aktif[playerid] = false;
  if (Konusuyor[playerid]) { new o = Konusuyor[playerid] - 1; Konusuyor[o] = 0; SendClientMessage(o, SARI, "Arama sonlandi."); }
  return 1;
}
public OnPlayerRequestClass(playerid, classid) { return 1; }
public OnPlayerRequestSpawn(playerid) { return Aktif[playerid] ? 1 : 0; }
public OnPlayerSpawn(playerid) {
  if (!Aktif[playerid]) return 1;
  if (aSpec[playerid]) { aSpec[playerid] = false; SetPlayerSkin(playerid, cSkin[playerid]); SetPlayerInterior(playerid, aInt[playerid]); SetPlayerVirtualWorld(playerid, 0); SetPlayerPos(playerid, aPos[playerid][0], aPos[playerid][1], aPos[playerid][2]); SetPlayerFacingAngle(playerid, aPos[playerid][3]); return 1; }
  ResetPlayerMoney(playerid); GivePlayerMoney(playerid, cCash[playerid]);
  SetPlayerSkin(playerid, cSkin[playerid]); SetPlayerScore(playerid, cLevel[playerid]); SetPlayerHealth(playerid, 100.0);
  if (hJail[playerid] > 0) { SetPlayerInterior(playerid, 6); SetPlayerPos(playerid, 264.6, 77.6, 1001.0); }
  new s[140], n[48]; RPAd(playerid, n);
  format(s, sizeof s, "Hos geldin %s! Menu icin /panel yaz.", n); SendClientMessage(playerid, MOR, s);
  if (Duyuru[0]) { format(s, sizeof s, "DUYURU: %s", Duyuru); SendClientMessage(playerid, SARI, s); }
  BasvuruUygula(playerid);
  SetTimerEx("SpawnDuzelt", 1500, false, "i", playerid);
  return 1;
}
public OnPlayerDeath(playerid, killerid, reason) {
  if (Aktif[playerid]) SetSpawnInfo(playerid, NO_TEAM, cSkin[playerid], 1177.5, -1323.5, 14.5, 270.0, 0, 0, 0, 0, 0, 0);
  return 1;
}
public OnPlayerStateChange(playerid, newstate, oldstate) {
  if (newstate == PLAYER_STATE_DRIVER) {
    new v = GetPlayerVehicleID(playerid);
    if (vSahip[v] && vSahip[v] - 1 != playerid) { RemovePlayerFromVehicle(playerid); Hata(playerid, "Bu arac baskasina ait."); }
  }
  return 1;
}
public OnPlayerPickUpPickup(playerid, pickupid) {
  for (new i = 0; i < MAXMULK; i++) if (mOn[i] && mPick[i] == pickupid) {
    new s[100];
    if (mOwner[i][0] == '-') format(s, sizeof s, "Satilik %s - Fiyat: $%d (/mulksatinal)", mTip[i] ? "isyeri" : "ev", mFiyat[i]);
    else format(s, sizeof s, "%s sahibi: %s (/gir)", mTip[i] ? "Isyeri" : "Ev", mOwner[i]);
    SendClientMessage(playerid, MOR, s);
  }
  return 1;
}
public OnPlayerText(playerid, text[]) {
  if (!Aktif[playerid]) return 0;
  if (hMute[playerid] > 0) { Hata(playerid, "Susturuldun."); return 0; }
  new s[160], n[48], Float:x, Float:y, Float:z; RPAd(playerid, n);
  if (Konusuyor[playerid]) { new o = Konusuyor[playerid] - 1; format(s, sizeof s, "(Telefon) %s: %s", n, text); SendClientMessage(o, SARI, s); SendClientMessage(playerid, SARI, s); return 0; }
  format(s, sizeof s, "%s: %s", n, text);
  GetPlayerPos(playerid, x, y, z);
  for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && Aktif[i] && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && IsPlayerInRangeOfPoint(i, 25.0, x, y, z)) SendClientMessage(i, BEYAZ, s);
  return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) {
  if (aAcik[playerid] && clickedid == INVALID_TEXT_DRAW) { AdminKapat(playerid); return 1; }
  if (sAcik[playerid] && clickedid == INVALID_TEXT_DRAW) SelectTextDraw(playerid, 0xFFD966FF);
  return 0;
}
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
  if (aAcik[playerid] && AdminTikla(playerid, playertextid)) return 1;
  if (!sAcik[playerid]) return 0;
  new sl = sSecim[playerid];
  if (playertextid == sTD[playerid][5]) { sSecim[playerid] = (sl + 3) % 4; SlotYenile(playerid); return 1; }
  if (playertextid == sTD[playerid][6]) { sSecim[playerid] = (sl + 1) % 4; SlotYenile(playerid); return 1; }
  if (playertextid == sTD[playerid][8]) {
    SecimKapat(playerid);
    if (hSlot[playerid][sl][0]) {
      Oyna(playerid, sl);
      if (!Aktif[playerid]) ShowSlots(playerid);
    } else {
      tSlot[playerid] = sl;
      ShowPlayerDialog(playerid, D_AD, DIALOG_STYLE_INPUT, "Yeni Karakter", "Karakter ADI (sadece harf):", "Ileri", "Geri");
    }
    return 1;
  }
  if (playertextid == sTD[playerid][10]) {
    if (!hSlot[playerid][sl][0]) return 1;
    SecimKapat(playerid);
    tSlot[playerid] = sl;
    ShowPlayerDialog(playerid, D_SIL, DIALOG_STYLE_MSGBOX, "Karakteri Sil", "Bu karakter KALICI olarak silinecek. Emin misin?", "Sil", "Iptal");
    return 1;
  }
  return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
  new s[300], i, f[64];
  if (AdminDialog(playerid, dialogid, response, listitem, inputtext)) return 1;
  switch (dialogid) {
    case D_KAYIT: {
      if (!response) return Kick(playerid), 1;
      if (strlen(inputtext) < 6) return ShowPlayerDialog(playerid, D_KAYIT, DIALOG_STYLE_PASSWORD, "DUKTUR RP - Kayit", "Sifre en az 6 karakter olmali:", "Kayit ol", "Cikis"), 1;
      hSifre[playerid] = Hash(inputtext);
      Giris[playerid] = true; HesapKaydet(playerid); ShowSlots(playerid); return 1;
    }
    case D_GIRIS: {
      if (!response) return Kick(playerid), 1;
      if (Hash(inputtext) != hSifre[playerid]) {
        if (++Deneme[playerid] >= 3) { Hata(playerid, "3 hatali deneme. Atildin."); SetTimerEx("KickGec", 500, false, "i", playerid); return 1; }
        return ShowPlayerDialog(playerid, D_GIRIS, DIALOG_STYLE_PASSWORD, "DUKTUR RP - Giris", "Yanlis sifre! Tekrar dene:", "Giris", "Cikis"), 1;
      }
      Giris[playerid] = true; HesapKaydet(playerid); ShowSlots(playerid); return 1;
    }
    case D_SLOT: {
      if (!response) return Kick(playerid), 1;
      tSlot[playerid] = listitem;
      if (hSlot[playerid][listitem][0]) return ShowPlayerDialog(playerid, D_SLOTMENU, DIALOG_STYLE_LIST, hSlot[playerid][listitem], "Oyna\nKarakteri Sil", "Sec", "Geri"), 1;
      return ShowPlayerDialog(playerid, D_AD, DIALOG_STYLE_INPUT, "Yeni Karakter", "Karakter ADI (sadece harf):", "Ileri", "Geri"), 1;
    }
    case D_SLOTMENU: {
      if (!response) return ShowSlots(playerid), 1;
      if (listitem == 0) return Oyna(playerid, tSlot[playerid]), 1;
      return ShowPlayerDialog(playerid, D_SIL, DIALOG_STYLE_MSGBOX, "Karakteri Sil", "Bu karakter KALICI olarak silinecek. Emin misin?", "Sil", "Iptal"), 1;
    }
    case D_SIL: {
      if (!response) return ShowSlots(playerid), 1;
      KYol(hSlot[playerid][tSlot[playerid]], f); fremove(f);
      hSlot[playerid][tSlot[playerid]][0] = 0; HesapKaydet(playerid); ShowSlots(playerid); return 1;
    }
    case D_AD: {
      if (!response) return ShowSlots(playerid), 1;
      if (!IsimGecerli(inputtext)) return ShowPlayerDialog(playerid, D_AD, DIALOG_STYLE_INPUT, "Yeni Karakter", "Gecersiz! 2-16 harf, rakam/sembol yok.\nKarakter ADI:", "Ileri", "Geri"), 1;
      format(tAd[playerid], 24, "%s", inputtext); Buyut(tAd[playerid]);
      return ShowPlayerDialog(playerid, D_SOYAD, DIALOG_STYLE_INPUT, "Yeni Karakter", "Karakter SOYADI:", "Ileri", "Geri"), 1;
    }
    case D_SOYAD: {
      if (!response) return ShowSlots(playerid), 1;
      if (!IsimGecerli(inputtext)) return ShowPlayerDialog(playerid, D_SOYAD, DIALOG_STYLE_INPUT, "Yeni Karakter", "Gecersiz! Karakter SOYADI:", "Ileri", "Geri"), 1;
      format(tSoyad[playerid], 24, "%s", inputtext); Buyut(tSoyad[playerid]);
      format(s, sizeof s, "%s_%s", tAd[playerid], tSoyad[playerid]); KYol(s, f);
      if (fexist(f)) return ShowPlayerDialog(playerid, D_AD, DIALOG_STYLE_INPUT, "Yeni Karakter", "Bu isim ALINMIS! Baska bir AD gir:", "Ileri", "Geri"), 1;
      return ShowPlayerDialog(playerid, D_YAS, DIALOG_STYLE_INPUT, "Yeni Karakter", "Karakter YASI (18-80):", "Ileri", "Geri"), 1;
    }
    case D_YAS: {
      if (!response) return ShowSlots(playerid), 1;
      i = strval(inputtext);
      if (i < 18 || i > 80) return ShowPlayerDialog(playerid, D_YAS, DIALOG_STYLE_INPUT, "Yeni Karakter", "Yas 18 ile 80 arasi olmali:", "Ileri", "Geri"), 1;
      tYas[playerid] = i;
      return ShowPlayerDialog(playerid, D_CINS, DIALOG_STYLE_LIST, "Cinsiyet", "Erkek\nKadin", "Ileri", "Geri"), 1;
    }
    case D_CINS: {
      if (!response) return ShowSlots(playerid), 1;
      tCins[playerid] = listitem;
      return ShowPlayerDialog(playerid, D_DOGUM, DIALOG_STYLE_INPUT, "Yeni Karakter", "Dogum yeri (sehir, harf):", "Ileri", "Geri"), 1;
    }
    case D_DOGUM: {
      if (!response) return ShowSlots(playerid), 1;
      if (!IsimGecerli(inputtext)) return ShowPlayerDialog(playerid, D_DOGUM, DIALOG_STYLE_INPUT, "Yeni Karakter", "Gecersiz! Dogum yeri (sadece harf):", "Ileri", "Geri"), 1;
      format(tDogum[playerid], 24, "%s", inputtext); Buyut(tDogum[playerid]);
      KarakterOlustur(playerid, random(6)); return 1;
    }
    case D_SKIN: {
      if (!response) return ShowSlots(playerid), 1;
      KarakterOlustur(playerid, listitem); return 1;
    }
    case D_MENU: {
      if (!response) return 1;
      new const cm[][] = {"/profil","/banka","/envanter","/belgeler","/meslek","/araclarim","/mulklerim","/telefon","/birlik","/basarimlar","/gorevler","/rapor","/basvur","/istatistik","/arkadaslar","/yardim"};
      new c2[24]; format(c2, sizeof c2, "%s", cm[listitem]); return OnPlayerCommandText(playerid, c2), 1;
    }
    case D_ARACAL: {
      if (!response) return 1;
      for (i = 0; i < 3; i++) if (!cVM[playerid][i]) break;
      if (i == 3) return Hata(playerid, "En fazla 3 arac sahibi olabilirsin."), 1;
      if (cBank[playerid] < AracFiyat[listitem]) return Hata(playerid, "Bankada yeterli para yok."), 1;
      cBank[playerid] -= AracFiyat[listitem]; cSpent[playerid] += AracFiyat[listitem];
      cVM[playerid][i] = AracModel[listitem]; format(cVP[playerid][i], 10, "DR%04d", random(10000));
      Basarim(playerid, 2); KarakterKaydet(playerid);
      format(s, sizeof s, "%s satin alindi! Plaka: %s. /araclarim ile cikar.", AracAd[listitem], cVP[playerid][i]); return Bilgi(playerid, s), 1;
    }
    case D_ARACLARIM: {
      if (!response || !cVM[playerid][listitem]) return 1;
      if (cVid[playerid][listitem]) AracPark(playerid, listitem); else AracCikar(playerid, listitem);
      return 1;
    }
    case D_MESLEK: {
      if (!response) return 1;
      if (MeslekBas[listitem]) return Hata(playerid, "Bu meslek icin /basvur yapmalisin."), 1;
      cJob[playerid] = listitem; if (listitem) Basarim(playerid, 1);
      format(s, sizeof s, "Yeni meslegin: %s", MeslekAd[listitem]); return Bilgi(playerid, s), 1;
    }
    case D_ENV: {
      if (!response || !cInv[playerid][listitem]) return 1;
      new Float:hp;
      GetPlayerHealth(playerid, hp);
      if (listitem == 0) SetPlayerHealth(playerid, hp + 10.0 > 100.0 ? 100.0 : hp + 10.0);
      else if (listitem == 1) SetPlayerHealth(playerid, hp + 20.0 > 100.0 ? 100.0 : hp + 20.0);
      else if (listitem == 2) SetPlayerHealth(playerid, 100.0);
      else if (listitem == 3) { if (!IsPlayerInAnyVehicle(playerid)) return Hata(playerid, "Bir aracin icinde olmalisin."), 1; RepairVehicle(GetPlayerVehicleID(playerid)); }
      cInv[playerid][listitem]--;
      format(s, sizeof s, "%s kullanildi.", EsyaAd[listitem]); return Bilgi(playerid, s), 1;
    }
    case D_MARKET: {
      if (!response) return 1;
      if (GetPlayerMoney(playerid) < EsyaFiyat[listitem]) return Hata(playerid, "Yeterli nakdin yok."), 1;
      if (!Env_Ekle(playerid, listitem, 1)) return Hata(playerid, "Envanter dolu (maks 40 agirlik)."), 1;
      GivePlayerMoney(playerid, -EsyaFiyat[listitem]); cSpent[playerid] += EsyaFiyat[listitem];
      format(s, sizeof s, "%s satin alindi.", EsyaAd[listitem]); return Bilgi(playerid, s), 1;
    }
    case D_BASVURU: {
      if (!response) return 1;
      for (i = 0; i < MAXBAS; i++) if (bOn[i] && bTur[i] == listitem && bDurum[i] < 2 && !strcmp(bKey[i], cKey[playerid], true)) return Hata(playerid, "Bu basvurun zaten beklemede."), 1;
      for (i = 0; i < MAXBAS; i++) if (!bOn[i]) break;
      if (i == MAXBAS) return Hata(playerid, "Basvuru listesi dolu."), 1;
      bOn[i] = 1; bTur[i] = listitem; bDurum[i] = 2; format(bKey[i], 34, "%s", cKey[playerid]); BasvuruKaydet();
      BasvuruUygula(playerid); return 1;
    }
    case D_RAPORTUR: {
      if (!response) return 1;
      tRapor[playerid] = listitem;
      return ShowPlayerDialog(playerid, D_RAPORMETIN, DIALOG_STYLE_INPUT, "Rapor", "Raporunu yaz (kanit icin F8 ile ekran goruntusu al):", "Gonder", "Iptal"), 1;
    }
    case D_RAPORMETIN: {
      if (!response || strlen(inputtext) < 5) return 1;
      for (i = 0; i < MAXRAPOR; i++) if (!rOn[i]) break;
      if (i == MAXRAPOR) return Hata(playerid, "Rapor listesi dolu."), 1;
      new n[MAX_PLAYER_NAME]; GetPlayerName(playerid, n, sizeof n);
      rOn[i] = 1; rTur[i] = tRapor[playerid]; rDurum[i] = 0; format(rSahip[i], 24, "%s", n); format(rMetin[i], 96, "%s", inputtext); Temizle(rMetin[i]); rCevap[i][0] = 0;
      RaporKaydet();
      format(s, sizeof s, "Rapor #%d olusturuldu.", i); Bilgi(playerid, s);
      format(s, sizeof s, "[RAPOR #%d] %s: %s", i, RaporTur[rTur[i]], rMetin[i]);
            return 1;
    }
    case D_TEL: {
      if (!response) return 1;
      if (listitem == 0) Bilgi(playerid, "Ara: /ara numara | SMS: /sms numara mesaj | Kapat: /kapat | Ac: /ac");
      else if (listitem == 1) { format(s, sizeof s, "Banka bakiyesi: $%d", cBank[playerid]); Bilgi(playerid, s); }
      else if (listitem == 2) ShowPlayerDialog(playerid, D_GPS, DIALOG_STYLE_LIST, "GPS", "All Saints Hastanesi\nLSPD\nBelediye\nUnity Station\nGPS Kapat", "Git", "Kapat");
      else if (listitem == 3) { new gy, gm, gd; getdate(gy, gm, gd); format(s, sizeof s, "Takvim: %02d.%02d.%d", gd, gm, gy); Bilgi(playerid, s); }
      else if (listitem == 4) Bilgi(playerid, "Not yazmak icin: /not metin");
      else if (listitem == 5) OnPlayerCommandText(playerid, "/arkadaslar");
      else if (listitem == 6) Bilgi(playerid, "Sosyal medya: /twt mesaj");
      else if (listitem == 7) Bilgi(playerid, "Acil cagri: /112");
      return 1;
    }
    case D_GPS: {
      if (!response) return 1;
      if (listitem == 4) DisablePlayerCheckpoint(playerid); else SetPlayerCheckpoint(playerid, GpsPos[listitem][0], GpsPos[listitem][1], GpsPos[listitem][2], 5.0);
      return 1;
    }
  }
  return 0;
}
public OnPlayerEnterCheckpoint(playerid) { DisablePlayerCheckpoint(playerid); Bilgi(playerid, "Hedefe ulastin."); return 1; }

public OnPlayerCommandText(playerid, cmdtext[]) {
  new idx = 0, cmd[24], a1[40], a2[40], s[400], t[96], i, id, n[48], nick[MAX_PLAYER_NAME], f[64];
  Tok(cmdtext, idx, cmd, sizeof cmd);
  if (!Giris[playerid]) return 1;
  if (AdminKomut(playerid, cmdtext)) return 1;

  KOMUT("/karakterdegis") { AKTIF; KarakterKaydet(playerid); for (i = 0; i < 3; i++) AracPark(playerid, i); Aktif[playerid] = false; TogglePlayerSpectating(playerid, 1); ShowSlots(playerid); return 1; }
  KOMUT("/yardim") {
    SendClientMessage(playerid, MOR, "/panel /profil /istatistik /banka /yatir /cek /gonder /envanter /market /ver /meslek /basvur /istifa");
    SendClientMessage(playerid, MOR, "/gir /cik /mulksatinal /mulksat /mulklerim /aracal /araclarim /aracsat /motor /telefon /sms /ara /ac /kapat /112 /not /twt");
    SendClientMessage(playerid, MOR, "/birlik /davet /davetkabul /rutbe /birliktenat /birlikayril /r /pm /arkadasekle /arkadaslar /rapor /gorevler /basarimlar");
    return 1;
  }
  KOMUT("/panel") {
    AKTIF;
    ShowPlayerDialog(playerid, D_MENU, DIALOG_STYLE_LIST, "DUKTUR RP - Panel", "Profilim\nBanka\nEnvanter\nBelgeler\nMeslek Merkezi\nAraclarim\nMulklerim\nTelefon\nBirlik\nBasarimlar\nGorevler\nRapor Merkezi\nBasvuru Merkezi\nIstatistikler\nArkadaslar\nYardim", "Ac", "Kapat");
    return 1;
  }
  KOMUT("/profil") {
    AKTIF; RPAd(playerid, n);
    format(s, sizeof s, "Karakter: %s | Yas: %d | Seviye: %d (XP %d/%d) | Sure: %d dk", n, cYas[playerid], cLevel[playerid], cXP[playerid], cLevel[playerid] * 100, cMin[playerid]);
    SendClientMessage(playerid, MOR, s);
    format(s, sizeof s, "Nakit: $%d | Banka: $%d | Meslek: %s | Birlik: %s (rutbe %d) | Tel: %d", GetPlayerMoney(playerid), cBank[playerid], MeslekAd[cJob[playerid]], BirlikAd[cFac[playerid]], cRank[playerid], cPhone[playerid]);
    SendClientMessage(playerid, MOR, s);
    return 1;
  }
  KOMUT("/istatistik") {
    AKTIF;
    format(s, sizeof s, "Toplam oyun: %d dk | Toplam kazanc: $%d | Toplam harcama: $%d | Basarim: ", cMin[playerid], cEarn[playerid], cSpent[playerid]);
    id = 0; for (i = 0; i < 9; i++) if (cBas[playerid] & (1 << i)) id++;
    format(t, sizeof t, "%d/9", id); strcat(s, t, sizeof s); SendClientMessage(playerid, MOR, s);
    return 1;
  }
  KOMUT("/banka") { AKTIF; format(s, sizeof s, "Banka: $%d | Nakit: $%d | IBAN: TR%d", cBank[playerid], GetPlayerMoney(playerid), 10000000 + (Hash(cKey[playerid]) & 0x3FFFFFF)); return Bilgi(playerid, s); }
  KOMUT("/yatir") {
    AKTIF; Tok(cmdtext, idx, a1, sizeof a1); id = strval(a1);
    if (id < 1 || id > 100000000) return Hata(playerid, "Kullanim: /yatir miktar");
    if (GetPlayerMoney(playerid) < id) return Hata(playerid, "Yetersiz nakit.");
    GivePlayerMoney(playerid, -id); cBank[playerid] += id; return Bilgi(playerid, "Para yatirildi.");
  }
  KOMUT("/cek") {
    AKTIF; Tok(cmdtext, idx, a1, sizeof a1); id = strval(a1);
    if (id < 1 || id > 100000000) return Hata(playerid, "Kullanim: /cek miktar");
    if (cBank[playerid] < id) return Hata(playerid, "Yetersiz bakiye.");
    cBank[playerid] -= id; GivePlayerMoney(playerid, id); return Bilgi(playerid, "Para cekildi.");
  }
  KOMUT("/gonder") {
    AKTIF; Tok(cmdtext, idx, a1, sizeof a1); Tok(cmdtext, idx, a2, sizeof a2); id = strval(a1); i = strval(a2);
    if (i < 1 || i > 100000000 || !a1[0]) return Hata(playerid, "Kullanim: /gonder oyuncuID miktar");
    if (!IDGecerli(id) || id == playerid) return Hata(playerid, "Gecersiz oyuncu.");
    if (cBank[playerid] < i) return Hata(playerid, "Yetersiz bakiye.");
    cBank[playerid] -= i; cBank[id] += i; RPAd(id, n);
    format(s, sizeof s, "%s kisisine $%d gonderdin.", n, i); Bilgi(playerid, s);
    RPAd(playerid, n); format(s, sizeof s, "%s sana $%d gonderdi.", n, i); Bilgi(id, s); return 1;
  }
  KOMUT("/envanter") {
    AKTIF; s[0] = 0;
    for (i = 0; i < 8; i++) { format(t, sizeof t, "%s x%d (agirlik %d)\n", EsyaAd[i], cInv[playerid][i], EsyaAgirlik[i]); strcat(s, t, sizeof s); }
    return ShowPlayerDialog(playerid, D_ENV, DIALOG_STYLE_LIST, "Envanter (secince kullanilir)", s, "Kullan", "Kapat"), 1;
  }
  KOMUT("/market") {
    AKTIF; s[0] = 0;
    for (i = 0; i < 8; i++) { format(t, sizeof t, "%s - $%d\n", EsyaAd[i], EsyaFiyat[i]); strcat(s, t, sizeof s); }
    return ShowPlayerDialog(playerid, D_MARKET, DIALOG_STYLE_LIST, "Market", s, "Satin al", "Kapat"), 1;
  }
  KOMUT("/ver") {
    AKTIF; Tok(cmdtext, idx, a1, sizeof a1); Tok(cmdtext, idx, a2, sizeof a2); id = strval(a1); i = strval(a2);
    new it = -1, adet; Tok(cmdtext, idx, t, sizeof t); adet = strval(t); if (adet < 1) adet = 1;
    for (new j = 0; j < 8; j++) if (!strcmp(EsyaAd[j], a2, true)) it = j;
    if (it == -1) return Hata(playerid, "Kullanim: /ver oyuncuID esyaAdi [adet] (Su, Ekmek, Maske...)");
    if (!IDGecerli(id) || id == playerid) return Hata(playerid, "Gecersiz oyuncu.");
    if (cInv[playerid][it] < adet) return Hata(playerid, "Yeterli esyan yok.");
    if (!Env_Ekle(id, it, adet)) return Hata(playerid, "Karsi tarafin envanteri dolu.");
    cInv[playerid][it] -= adet; format(s, sizeof s, "%d adet %s verildi.", adet, EsyaAd[it]); return Bilgi(playerid, s);
  }
  KOMUT("/meslek") {
    AKTIF; s[0] = 0;
    for (i = 0; i < 12; i++) { format(t, sizeof t, "%s - Maas $%d/saat%s\n", MeslekAd[i], MeslekMaas[i], MeslekBas[i] ? " (basvuru)" : ""); strcat(s, t, sizeof s); }
    return ShowPlayerDialog(playerid, D_MESLEK, DIALOG_STYLE_LIST, "Meslek Merkezi", s, "Meslegi Al", "Kapat"), 1;
  }
  KOMUT("/istifa") { AKTIF; cJob[playerid] = 0; cFac[playerid] = 0; cRank[playerid] = 0; return Bilgi(playerid, "Isten ayrildin."); }
  KOMUT("/basvur") {
    AKTIF; s[0] = 0;
    for (i = 0; i < 5; i++) { format(t, sizeof t, "%s Basvurusu\n", BasvuruTur[i]); strcat(s, t, sizeof s); }
    return ShowPlayerDialog(playerid, D_BASVURU, DIALOG_STYLE_LIST, "Basvuru Merkezi", s, "Basvur", "Kapat"), 1;
  }
  KOMUT("/basvurularim") {
    AKTIF; BasvuruUygula(playerid); s[0] = 0;
    for (i = 0; i < MAXBAS; i++) if (bOn[i] && !strcmp(bKey[i], cKey[playerid], true)) {
      format(t, sizeof t, "%s: %s\n", BasvuruTur[bTur[i]], bDurum[i] == 0 ? "Beklemede" : (bDurum[i] == 1 ? "Inceleniyor" : (bDurum[i] == 3 ? "Reddedildi" : "Kabul edildi")));
      strcat(s, t, sizeof s);
    }
    if (!s[0]) strcat(s, "Basvurun yok.", sizeof s);
    return ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "Basvurularim", s, "Kapat", ""), 1;
  }
  KOMUT("/belgeler") {
    AKTIF; format(s, sizeof s, "Kimlik: %s\nEhliyet: %s\nSilah Ruhsati: %s\n\n/kimlik ile kimligini, /kimlikgoster ID ile baskasina gosterirsin. Ehliyet icin /ehliyetal ($500).", (cBelge[playerid] & 1) ? "VAR" : "YOK", (cBelge[playerid] & 2) ? "VAR" : "YOK", (cBelge[playerid] & 4) ? "VAR" : "YOK");
    return ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "Belgeler", s, "Kapat", ""), 1;
  }
  KOMUT("/kimlik") { AKTIF; Kimlik(playerid, playerid); return 1; }
  KOMUT("/kimlikgoster") { AKTIF; Tok(cmdtext, idx, a1, sizeof a1); id = strval(a1); if (!IDGecerli(id)) return Hata(playerid, "Gecersiz oyuncu."); Kimlik(id, playerid); return 1; }
  KOMUT("/ehliyetal") {
    AKTIF; if (cBelge[playerid] & 2) return Hata(playerid, "Zaten ehliyetin var.");
    if (cBank[playerid] < 500) return Hata(playerid, "Bankada $500 olmali.");
    cBank[playerid] -= 500; cSpent[playerid] += 500; cBelge[playerid] |= 2; return Bilgi(playerid, "Ehliyet alindi.");
  }
  // ----- Mulk -----
  KOMUT("/gir") {
    AKTIF; id = YakinMulk(playerid); if (id == -1) return Hata(playerid, "Yakinda mulk yok.");
    if (mOwner[id][0] == '-') return Hata(playerid, "Bu mulk satilik. /mulksatinal");
    if (mTip[id] == 0 && strcmp(mOwner[id], cKey[playerid], true)) return Hata(playerid, "Bu ev senin degil.");
    SetPlayerInterior(playerid, 3); SetPlayerVirtualWorld(playerid, 100 + id); SetPlayerPos(playerid, 2496.05, -1695.17, 1014.74); return 1;
  }
  KOMUT("/cik") {
    AKTIF; id = GetPlayerVirtualWorld(playerid) - 100; if (id < 0 || id >= MAXMULK || !mOn[id]) return Hata(playerid, "Bir mulkun icinde degilsin.");
    SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0); SetPlayerPos(playerid, mX[id], mY[id], mZ[id] + 0.5); return 1;
  }
  KOMUT("/mulksatinal") {
    AKTIF; id = YakinMulk(playerid); if (id == -1) return Hata(playerid, "Yakinda mulk yok.");
    if (mOwner[id][0] != '-') return Hata(playerid, "Bu mulk satilik degil.");
    for (i = 0; i < 3; i++) if (!cMulk[playerid][i]) break;
    if (i == 3) return Hata(playerid, "En fazla 3 mulk sahibi olabilirsin.");
    if (cBank[playerid] < mFiyat[id]) return Hata(playerid, "Bankada yeterli para yok.");
    cBank[playerid] -= mFiyat[id]; cSpent[playerid] += mFiyat[id]; cMulk[playerid][i] = id + 1; format(mOwner[id], 34, "%s", cKey[playerid]);
    MulkYenile(id); MulkKaydet(); Basarim(playerid, 3); KarakterKaydet(playerid); return Bilgi(playerid, "Tebrikler, mulk satin alindi!");
  }
  KOMUT("/mulksat") {
    AKTIF; id = YakinMulk(playerid); if (id == -1 || strcmp(mOwner[id], cKey[playerid], true)) return Hata(playerid, "Sahibi oldugun bir mulkun yaninda olmalisin.");
    cBank[playerid] += mFiyat[id] * 7 / 10; for (i = 0; i < 3; i++) if (cMulk[playerid][i] == id + 1) cMulk[playerid][i] = 0;
    mOwner[id][0] = '-'; mOwner[id][1] = 0; MulkYenile(id); MulkKaydet(); KarakterKaydet(playerid);
    format(s, sizeof s, "Mulk satildi, bankana $%d yatti.", mFiyat[id] * 7 / 10); return Bilgi(playerid, s);
  }
  KOMUT("/mulklerim") {
    AKTIF; s[0] = 0;
    for (i = 0; i < 3; i++) if (cMulk[playerid][i]) { id = cMulk[playerid][i] - 1; format(t, sizeof t, "%s #%d - Deger $%d\n", mTip[id] ? "Isyeri" : "Ev", id, mFiyat[id]); strcat(s, t, sizeof s); }
    if (!s[0]) strcat(s, "Mulkun yok.", sizeof s);
    return ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "Mulklerim", s, "Kapat", ""), 1;
  }
  // ----- Arac -----
  KOMUT("/aracal") {
    AKTIF; s[0] = 0;
    for (i = 0; i < 10; i++) { format(t, sizeof t, "%s - $%d\n", AracAd[i], AracFiyat[i]); strcat(s, t, sizeof s); }
    return ShowPlayerDialog(playerid, D_ARACAL, DIALOG_STYLE_LIST, "Arac Galerisi", s, "Satin al", "Kapat"), 1;
  }
  KOMUT("/araclarim") {
    AKTIF; s[0] = 0;
    for (i = 0; i < 3; i++) { if (cVM[playerid][i]) format(t, sizeof t, "Model %d - Plaka %s [%s]\n", cVM[playerid][i], cVP[playerid][i], cVid[playerid][i] ? "Disarida" : "Garajda"); else format(t, sizeof t, "[Bos slot]\n"); strcat(s, t, sizeof s); }
    return ShowPlayerDialog(playerid, D_ARACLARIM, DIALOG_STYLE_LIST, "Garajim (sec: cikar/park et)", s, "Sec", "Kapat"), 1;
  }
  KOMUT("/aracsat") {
    AKTIF; Tok(cmdtext, idx, a1, sizeof a1); id = strval(a1) - 1;
    if (id < 0 || id > 2 || !cVM[playerid][id]) return Hata(playerid, "Kullanim: /aracsat slot(1-3)");
    for (i = 0; i < 10; i++) if (AracModel[i] == cVM[playerid][id]) break;
    AracPark(playerid, id); cBank[playerid] += AracFiyat[i] * 6 / 10; cVM[playerid][id] = 0; cVP[playerid][id][0] = 0;
    format(s, sizeof s, "Arac satildi, bankana $%d yatti.", AracFiyat[i] * 6 / 10); return Bilgi(playerid, s);
  }
  KOMUT("/motor") {
    AKTIF; if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Hata(playerid, "Surucu olmalisin.");
    new v = GetPlayerVehicleID(playerid), e, l, a, d, b, bo, o;
    GetVehicleParamsEx(v, e, l, a, d, b, bo, o); SetVehicleParamsEx(v, !e, l, a, d, b, bo, o);
    return Bilgi(playerid, "Motor durumu degistirildi.");
  }
  // ----- Telefon -----
  KOMUT("/telefon") { AKTIF; return ShowPlayerDialog(playerid, D_TEL, DIALOG_STYLE_LIST, "Telefon", "Rehber / Arama\nBanka\nGPS\nTakvim\nNotlar\nKisiler\nSosyal Medya\nAcil Cagri", "Sec", "Kapat"), 1; }
  KOMUT("/sms") {
    AKTIF; Tok(cmdtext, idx, a1, sizeof a1); Kalan(cmdtext, idx, t);
    for (i = 0; i < MAX_PLAYERS; i++) if (IDGecerli(i) && cPhone[i] == strval(a1) && a1[0]) {
      format(s, sizeof s, "SMS (%d): %s", cPhone[playerid], t); SendClientMessage(i, SARI, s); return Bilgi(playerid, "SMS gonderildi.");
    }
    return Hata(playerid, "Kullanim: /sms numara mesaj (numara ulasilamiyor olabilir).");
  }
  KOMUT("/ara") {
    AKTIF; Tok(cmdtext, idx, a1, sizeof a1);
    for (i = 0; i < MAX_PLAYERS; i++) if (IDGecerli(i) && i != playerid && cPhone[i] == strval(a1) && a1[0]) {
      Aranan[i] = playerid + 1; format(s, sizeof s, "%d numarali kisi seni ariyor! /ac ile ac.", cPhone[playerid]); SendClientMessage(i, SARI, s); return Bilgi(playerid, "Caliyor...");
    }
    return Hata(playerid, "Kullanim: /ara numara (ulasilamiyor olabilir).");
  }
  KOMUT("/ac") {
    AKTIF; if (!Aranan[playerid]) return Hata(playerid, "Seni arayan yok."); id = Aranan[playerid] - 1; Aranan[playerid] = 0;
    if (!IDGecerli(id)) return Hata(playerid, "Arayan kapatti.");
    Konusuyor[playerid] = id + 1; Konusuyor[id] = playerid + 1; Bilgi(playerid, "Konusma basladi. Yazdiklarin telefona gider. /kapat"); return Bilgi(id, "Acti! Konusabilirsin. /kapat");
  }
  KOMUT("/kapat") {
    AKTIF; if (!Konusuyor[playerid]) return Hata(playerid, "Aramada degilsin."); id = Konusuyor[playerid] - 1; Konusuyor[playerid] = 0; Konusuyor[id] = 0; Bilgi(id, "Arama sonlandi."); return Bilgi(playerid, "Arama sonlandi.");
  }
  KOMUT("/112") {
    AKTIF; GetPlayerName(playerid, nick, sizeof nick); RPAd(playerid, n); format(s, sizeof s, "ACIL CAGRI: %s (tel %d) yardim istiyor!", n, cPhone[playerid]);
    for (i = 0; i < MAX_PLAYERS; i++) if (IDGecerli(i) && (cFac[i] == 1 || cFac[i] == 2)) SendClientMessage(i, KIRMIZI, s);
    return Bilgi(playerid, "Acil cagrin iletildi.");
  }
  KOMUT("/not") { AKTIF; Kalan(cmdtext, idx, t, 80); if (!t[0]) { format(s, sizeof s, "Notun: %s", cNot[playerid][0] ? cNot[playerid] : "(bos)"); return Bilgi(playerid, s); } format(cNot[playerid], 80, "%s", t); return Bilgi(playerid, "Not kaydedildi."); }
  KOMUT("/twt") { AKTIF; Kalan(cmdtext, idx, t); if (!t[0]) return Hata(playerid, "Kullanim: /twt mesaj"); RPAd(playerid, n); format(s, sizeof s, "[Twitter] @%s_%s: %s", cAd[playerid], cSoyad[playerid], t); SendClientMessageToAll(0x55AAFFFF, s); return 1; }
  // ----- Sosyal -----
  KOMUT("/pm") {
    AKTIF; Tok(cmdtext, idx, a1, sizeof a1); Kalan(cmdtext, idx, t); id = strval(a1);
    if (!IDGecerli(id) || !t[0]) return Hata(playerid, "Kullanim: /pm oyuncuID mesaj");
    RPAd(playerid, n); format(s, sizeof s, "(PM) %s: %s", n, t); SendClientMessage(id, 0xFFAA55FF, s); return Bilgi(playerid, "PM gonderildi.");
  }
  KOMUT("/arkadasekle") {
    AKTIF; Tok(cmdtext, idx, a1, sizeof a1); id = strval(a1); if (!IDGecerli(id) || id == playerid) return Hata(playerid, "Gecersiz oyuncu.");
    for (i = 0; i < 5; i++) if (!cArk[playerid][i][0]) break;
    if (i == 5) return Hata(playerid, "Arkadas listesi dolu (5).");
    format(cArk[playerid][i], 24, "%s", cKey[id]); return Bilgi(playerid, "Arkadas eklendi.");
  }
  KOMUT("/arkadaslar") {
    AKTIF; s[0] = 0; for (i = 0; i < 5; i++) if (cArk[playerid][i][0]) { format(t, sizeof t, "%d) %s\n", i + 1, cArk[playerid][i]); strcat(s, t, sizeof s); }
    if (!s[0]) strcat(s, "Arkadasin yok. /arkadasekle ID", sizeof s);
    return ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "Arkadaslar", s, "Kapat", ""), 1;
  }
  KOMUT("/arkadassil") { AKTIF; Tok(cmdtext, idx, a1, sizeof a1); id = strval(a1) - 1; if (id < 0 || id > 4) return Hata(playerid, "Kullanim: /arkadassil 1-5"); cArk[playerid][id][0] = 0; return Bilgi(playerid, "Silindi."); }
  // ----- Birlik -----
  KOMUT("/birlik") {
    AKTIF; if (!cFac[playerid]) return Hata(playerid, "Bir birlikte degilsin.");
    format(s, sizeof s, "Birlik: %s | Rutbe: %d | Cevrimici uyeler:", BirlikAd[cFac[playerid]], cRank[playerid]); SendClientMessage(playerid, MOR, s);
    for (i = 0; i < MAX_PLAYERS; i++) if (IDGecerli(i) && cFac[i] == cFac[playerid]) { RPAd(i, n); format(s, sizeof s, " - %s (rutbe %d)", n, cRank[i]); SendClientMessage(playerid, BEYAZ, s); }
    return 1;
  }
  KOMUT("/davet") {
    AKTIF; if (cRank[playerid] < 4 || !cFac[playerid]) return Hata(playerid, "Rutben 4+ olmali."); Tok(cmdtext, idx, a1, sizeof a1); id = strval(a1);
    if (!IDGecerli(id) || cFac[id]) return Hata(playerid, "Gecersiz ya da baska birlikte.");
    Davet[id] = cFac[playerid]; format(s, sizeof s, "%s birligine davet edildin. /davetkabul", BirlikAd[cFac[playerid]]); Bilgi(id, s); return Bilgi(playerid, "Davet gonderildi.");
  }
  KOMUT("/davetkabul") { AKTIF; if (!Davet[playerid]) return Hata(playerid, "Davetin yok."); cFac[playerid] = Davet[playerid]; cRank[playerid] = 1; Davet[playerid] = 0; Basarim(playerid, 8); return Bilgi(playerid, "Birlige katildin."); }
  KOMUT("/rutbe") {
    AKTIF; if (cRank[playerid] < 5) return Hata(playerid, "Sadece lider."); Tok(cmdtext, idx, a1, sizeof a1); Tok(cmdtext, idx, a2, sizeof a2); id = strval(a1); i = strval(a2);
    if (!IDGecerli(id) || cFac[id] != cFac[playerid] || i < 1 || i > 4) return Hata(playerid, "Kullanim: /rutbe ID 1-4");
    cRank[id] = i; Bilgi(id, "Rutben degistirildi."); return Bilgi(playerid, "Tamam.");
  }
  KOMUT("/birliktenat") {
    AKTIF; if (cRank[playerid] < 4) return Hata(playerid, "Rutben 4+ olmali."); Tok(cmdtext, idx, a1, sizeof a1); id = strval(a1);
    if (!IDGecerli(id) || id == playerid || cFac[id] != cFac[playerid] || cRank[id] >= cRank[playerid]) return Hata(playerid, "Gecersiz.");
    cFac[id] = 0; cRank[id] = 0; Bilgi(id, "Birlikten atildin."); return Bilgi(playerid, "Atildi.");
  }
  KOMUT("/birlikayril") { AKTIF; cFac[playerid] = 0; cRank[playerid] = 0; return Bilgi(playerid, "Birlikten ayrildin."); }
  KOMUT("/r") {
    AKTIF; if (!cFac[playerid]) return Hata(playerid, "Birlikte degilsin."); Kalan(cmdtext, idx, t); RPAd(playerid, n);
    format(s, sizeof s, "[%s] %s: %s", BirlikAd[cFac[playerid]], n, t); for (i = 0; i < MAX_PLAYERS; i++) if (IDGecerli(i) && cFac[i] == cFac[playerid]) SendClientMessage(i, 0x55FFAAFF, s); return 1;
  }
  // ----- Rapor / Ceza / Gorev / Basarim / Duyuru -----
  KOMUT("/rapor") {
    AKTIF; s[0] = 0; for (i = 0; i < 7; i++) { format(t, sizeof t, "%s\n", RaporTur[i]); strcat(s, t, sizeof s); }
    return ShowPlayerDialog(playerid, D_RAPORTUR, DIALOG_STYLE_LIST, "Rapor Merkezi", s, "Sec", "Kapat"), 1;
  }
  KOMUT("/raporlarim") {
    AKTIF; GetPlayerName(playerid, nick, sizeof nick); s[0] = 0;
    for (i = 0; i < MAXRAPOR; i++) if (rOn[i] && !strcmp(rSahip[i], nick, true)) { format(t, sizeof t, "#%d [%s] %s\nCevap: %s\n\n", i, rDurum[i] ? "Cevaplandi" : "Acik", rMetin[i], rCevap[i][0] ? rCevap[i] : "-"); strcat(s, t, sizeof s); }
    if (!s[0]) strcat(s, "Raporun yok.", sizeof s);
    return ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "Raporlarim", s, "Kapat", ""), 1;
  }
  KOMUT("/gorevler") {
    AKTIF; format(s, sizeof s, "Gunluk: 30 dk oyna (%d/30) %s -> $2000\nHaftalik: 300 dk oyna (%d/300) %s -> $15000", cGMin[playerid], (cGor[playerid] & 1) ? "[TAMAM]" : "", cWMin[playerid], (cGor[playerid] & 2) ? "[TAMAM]" : "");
    return ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "Gorev Merkezi", s, "Kapat", ""), 1;
  }
  KOMUT("/basarimlar") {
    AKTIF; s[0] = 0; for (i = 0; i < 9; i++) { format(t, sizeof t, "[%s] %s\n", (cBas[playerid] & (1 << i)) ? "X" : " ", BasarimAd[i]); strcat(s, t, sizeof s); }
    return ShowPlayerDialog(playerid, D_YOK, DIALOG_STYLE_MSGBOX, "Basarimlar", s, "Kapat", ""), 1;
  }

  return 0;
}
