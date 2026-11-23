// DUKTUR RP - Tam Roleplay Gamemode (SA-MP 0.3.7, ek plugin yok)
// Gerekli klasorler: scriptfiles/duktur/hesap  ve  scriptfiles/duktur/karakter
#include <a_samp>

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

enum { D_YOK, D_KAYIT, D_GIRIS, D_SLOT, D_SLOTMENU, D_SIL, D_AD, D_SOYAD, D_YAS, D_CINS, D_SKIN, D_DOGUM, D_MENU, D_ARACAL, D_ARACLARIM, D_MESLEK, D_ENV, D_MARKET, D_BASVURU, D_RAPORTUR, D_RAPORMETIN, D_TEL, D_GPS }

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
new hSifre[MAX_PLAYERS], hAdm[MAX_PLAYERS], hBan[MAX_PLAYERS], hWarn[MAX_PLAYERS], hMute[MAX_PLAYERS], hJail[MAX_PLAYERS];
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

forward Dakika();
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
  WI(h, "pass", hSifre[playerid]); WI(h, "admin", hAdm[playerid]); WI(h, "ban", hBan[playerid]);
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
  if (GetPlayerInterior(p) == 0 && GetPlayerVirtualWorld(p) == 0) { GetPlayerPos(p, x, y, z); cX[p] = x; cY[p] = y; cZ[p] = z; }
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
stock ShowSlots(playerid) {
  new s[256], t[48];
  for (new i = 0; i < 4; i++) {
    if (hSlot[playerid][i][0]) { format(t, sizeof t, "Slot %d: %s\n", i + 1, hSlot[playerid][i]); }
    else format(t, sizeof t, "Slot %d: [BOS] Yeni karakter\n", i + 1);
    strcat(s, t, sizeof s);
  }
  SetPlayerCameraPos(playerid, 1760.0, -1910.0, 40.0); SetPlayerCameraLookAt(playerid, 1759.0, -1898.0, 13.5);
  ShowPlayerDialog(playerid, D_SLOT, DIALOG_STYLE_LIST, "DUKTUR RP - Karakter Sec", s, "Sec", "Cikis");
}
stock Oyna(playerid, slot) {
  if (!KarakterYukle(playerid, hSlot[playerid][slot])) return Hata(playerid, "Karakter dosyasi bulunamadi.");
  cSlot[playerid] = slot; Aktif[playerid] = true;
  for (new i = 0; i < 3; i++) if (cMulk[playerid][i] && (!mOn[cMulk[playerid][i] - 1] || strcmp(mOwner[cMulk[playerid][i] - 1], cKey[playerid], true))) cMulk[playerid][i] = 0;
  if (cX[playerid] == 0.0 && cY[playerid] == 0.0) { cX[playerid] = 1759.0; cY[playerid] = -1898.1; cZ[playerid] = 13.6; }
  SetSpawnInfo(playerid, NO_TEAM, cSkin[playerid], cX[playerid], cY[playerid], cZ[playerid] + 0.5, 0.0, 0, 0, 0, 0, 0, 0);
  TogglePlayerSpectating(playerid, 0);
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

// ---------- Callbacklar ----------
main() {}

public OnGameModeInit() {
  SetGameModeText("DUKTUR RP");
  AddPlayerClass(0, 1759.0, -1898.1, 13.6, 0.0, 0, 0, 0, 0, 0, 0);
  DisableInteriorEnterExits(); UsePlayerPedAnims(); EnableStuntBonusForAll(0);
  MulkYukle(); RaporYukle(); BasvuruYukle();
  SetTimer("Dakika", 60000, true);
  Etkinlik[0] = 0; Duyuru[0] = 0;
  return 1;
}
public OnGameModeExit() { for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i)) { KarakterKaydet(i); if (Giris[i]) HesapKaydet(i); } return 1; }

public OnPlayerConnect(playerid) {
  Giris[playerid] = false; Aktif[playerid] = false; Deneme[playerid] = 0; Davet[playerid] = 0; Aranan[playerid] = 0; Konusuyor[playerid] = 0; Katildi[playerid] = false;
  hSifre[playerid] = 0; hAdm[playerid] = 0; hBan[playerid] = 0; hWarn[playerid] = 0; hMute[playerid] = 0; hJail[playerid] = 0; hBanSebep[playerid][0] = 0;
  for (new i = 0; i < 4; i++) hSlot[playerid][i][0] = 0;
  KarakterSifirla(playerid);
  TogglePlayerSpectating(playerid, 1);
  SetPlayerCameraPos(playerid, 1760.0, -1910.0, 40.0); SetPlayerCameraLookAt(playerid, 1759.0, -1898.0, 13.5);
  SendClientMessage(playerid, MOR, "DUKTUR RP - YOUR LIFE, YOUR STORY, YOUR ROLEPLAY.");
  if (HesapYukle(playerid)) {
    if (hBan[playerid]) { new s[100]; format(s, sizeof s, "Hesabin yasakli. Sebep: %s", hBanSebep[playerid]); SendClientMessage(playerid, KIRMIZI, s); SetTimerEx("KickGec", 800, false, "i", playerid); return 1; }
    ShowPlayerDialog(playerid, D_GIRIS, DIALOG_STYLE_PASSWORD, "DUKTUR RP - Giris", "Hesabin kayitli. Sifreni gir:", "Giris", "Cikis");
  } else ShowPlayerDialog(playerid, D_KAYIT, DIALOG_STYLE_PASSWORD, "DUKTUR RP - Kayit", "Hesabin yok. Bir sifre belirle (en az 6 karakter):", "Kayit ol", "Cikis");
  return 1;
}
public OnPlayerDisconnect(playerid, reason) {
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
  ResetPlayerMoney(playerid); GivePlayerMoney(playerid, cCash[playerid]);
  SetPlayerSkin(playerid, cSkin[playerid]); SetPlayerScore(playerid, cLevel[playerid]); SetPlayerHealth(playerid, 100.0);
  if (hJail[playerid] > 0) { SetPlayerInterior(playerid, 6); SetPlayerPos(playerid, 264.6, 77.6, 1001.0); }
  new s[140], n[48]; RPAd(playerid, n);
  format(s, sizeof s, "Hos geldin %s! Menu icin /panel yaz.", n); SendClientMessage(playerid, MOR, s);
  if (Duyuru[0]) { format(s, sizeof s, "DUYURU: %s", Duyuru); SendClientMessage(playerid, SARI, s); }
  BasvuruUygula(playerid);
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

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
  new s[300], i, f[64];
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
      return ShowPlayerDialog(playerid, D_SKIN, DIALOG_STYLE_LIST, "Gorunum", "Gorunum 1\nGorunum 2\nGorunum 3\nGorunum 4\nGorunum 5\nGorunum 6", "Olustur", "Geri"), 1;
    }
    case D_SKIN: {
      if (!response) return ShowSlots(playerid), 1;
      new p = playerid;
      KarakterSifirla(p);
      format(cAd[p], 24, "%s", tAd[p]); format(cSoyad[p], 24, "%s", tSoyad[p]); format(cDogum[p], 24, "%s", tDogum[p]);
      cYas[p] = tYas[p]; cCins[p] = tCins[p]; cSkin[p] = tCins[p] ? SkinK[listitem] : SkinE[listitem];
      cBoy[p] = 160 + random(35); cKilo[p] = 55 + random(40); cKan[p] = random(8); cPhone[p] = 100000 + random(899999);
      cBank[p] = 5000; cCash[p] = 500; cBelge[p] = 1; cInv[p][0] = 2; cInv[p][1] = 2; cBas[p] = 1;
      format(cKey[p], 34, "%s_%s", cAd[p], cSoyad[p]);
      format(hSlot[p][tSlot[p]], 34, "%s", cKey[p]); Aktif[p] = true; KarakterKaydet(p); HesapKaydet(p);
      Aktif[p] = false; Oyna(p, tSlot[p]);
      return 1;
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
