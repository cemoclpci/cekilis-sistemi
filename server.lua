local cekilisAktif = false
local katilanlar = {}
local founderYetki = "founder" -- Değiştirilebilir, özel yetki adı
local cekilisSoru = ""

function cekilisOlustur(_, soru)
    if cekilisAktif then
        outputChatBox("Zaten bir çekiliş aktif durumda.")
        return
    end
    
    local yetki = getPlayerACLGroup(getPlayerFromName(getPlayerName(source)))
    if not isObjectInACLGroup("user."..yetki, aclGetGroup(founderYetki)) then
        outputChatBox("Bu komutu kullanmak için gerekli yetkiye sahip değilsiniz.")
        return
    end
    
    if not soru or soru == "" then
        outputChatBox("Lütfen bir çekiliş sorusu belirtin.")
        return
    end
    
    cekilisAktif = true
    katilanlar = {}
    cekilisSoru = soru
    
    outputChatBox("Çekiliş oluşturuldu! Çekilişe katılmak için /cekiliskatil komutunu kullanabilirsiniz.")
    outputChatBox("Çekilişe katılan oyuncular çekiliş sonunda bir mesaj alacak.")
end
addCommandHandler("cekilisolustur", cekilisOlustur)

function katil()
    if not cekilisAktif then
        outputChatBox("Şu anda bir çekiliş aktif değil.")
        return
    end
    
    if katilanlar[source] then
        outputChatBox("Zaten çekilişe katıldınız.")
        return
    end
    
    katilanlar[source] = getPlayerName(source)
    outputChatBox("Çekilişe katıldınız! İyi şanslar!")
end
addCommandHandler("cekiliskatil", katil)

function katilanlarKomut(player)
    local yetki = getPlayerACLGroup(getPlayerFromName(getPlayerName(player)))
    if not isObjectInACLGroup("user."..yetki, aclGetGroup(founderYetki)) then
        outputChatBox("Bu komutu kullanmak için gerekli yetkiye sahip değilsiniz.", player)
        return
    end
    
    if not cekilisAktif then
        outputChatBox("Şu anda bir çekiliş aktif değil.", player)
        return
    end
    
    if next(katilanlar) == nil then
        outputChatBox("Çekilişe katılan oyuncu bulunmamaktadır.", player)
        return
    end
    
    local index = 1
    for _, playerName in pairs(katilanlar) do
        outputChatBox("Katılan oyuncu ["..index.."]: "..playerName, player)
        index = index + 1
    end
end
addCommandHandler("katilanlar", katilanlarKomut)

function cekilisSonucu()
    local yetki = getPlayerACLGroup(getPlayerFromName(getPlayerName(source)))
    if not isObjectInACLGroup("user."..yetki, aclGetGroup(founderYetki)) then
        outputChatBox("Bu komutu kullanmak için gerekli yetkiye sahip değilsiniz.")
        return
    end
    
    if not cekilisAktif then
        outputChatBox("Şu anda bir çekiliş aktif değil.")
        return
    end
    
    if next(katilanlar) == nil then
        outputChatBox("Çekilişe katılan oyuncu bulunmamaktadır.")
        return
    end
    
    local kazanan = table.random(katilanlar)
    outputChatBox("Çekiliş sonucunda "..kazanan.." isimli oyuncu kazandı!")
    
    cekilisAktif = false
    katilanlar = {}
    cekilisSoru = ""
end
addCommandHandler("cekilissonucu", cekilisSonucu)

function sendNotificationToParticipants()
    if not cekilisAktif or next(katilanlar) == nil or cekilisSoru == "" then
        return
    end
    
    for player, _ in pairs(katilanlar) do
        outputChatBox("Çekiliş başladı! "..cekilisSoru.." cevabıyla katılmak için /cekiliskatil komutunu kullanın.", player)
    end
end
addEventHandler("onResourceStart", resourceRoot, sendNotificationToParticipants)
