function slashdamage(self,gong,shou)  --������һ�����������Լ��㣬һ��ɱ�ڲ��������е�������ʱ��������ɵ��˺�
    local pre = 1     --Ĭ�Ͽ����һ���˺�
	local amr=shou:getArmor()
	--�������ж϶����Ƿ��м��ܹ��Ź�������
	local zj = self.room:findPlayerBySkillName("guidao")
	local sm = self.room:findPlayerBySkillName("guicai")
	local ssm = self.room:findPlayerBySkillName("jilve")
	local godlikefriend = false
	if (zj and self:isFriend(zj) and self:canRetrial(zj)) or
	    (sm and self:isFriend(sm) and sm:getHandcardNum() >= 2) or
		(ssm and self:isFriend(ssm) and ssm:getHandcardNum() >= 2 and ssm:getMark("@bear")) then
        godlikefriend = true
    end		
	
	--��������������ļ��㣺
	--�����ɱ�����а��ԣ��ټף���ô�˺�Ϊ0
	--���������֣���ȸ���Ŷ����������㴥����������ô���µ����˺�ֵΪ1��2
	if ame then
	    if amr:objectName()=="EightDiagram" or shou:hasSkill("bazhen") or amr:isKindOf("Vine") then
		    pre = 0
		end
	    if (amr:objectName()=="EightDiagram" or shou:hasSkill("bazhen")) and (gong:hasWeapon("QinggangSword") or godlikefriend == true) then
		    pre = 1
		end
		if amr:isKindOf("Vine") and gong:hasWeapon("Fan") then
		    pre = 2
		end
		if amr:isKindOf("Vine") and gong:hasWeapon("QinggangSword") then
		    pre = 1
		end
		if not amr:objectName()=="SilverLion" and gong:hasWeapon("GudingBlade") and shou:isKongcheng() then
		    pre = 2
		end
	else
	    if gong:hasWeapon("GudingBlade") and shou:isKongcheng() then
		    pre = 2
		end
	end
	--����Ŀ���ǣ������ɱ�Ľ�ɫӵ�м������롢�׻������ҡ���ꡢ����ȵȼ���ʱ�����µ����˺�ֵΪ0
	--���Ա������������ӵ���߳�ɱ
	if self:slashProhibit(nil, shou) then
	    pre = 0
	end
	--�����һ�Σ����������ճ��ˣ���ô���µ����˺�Ϊ-100
	--֮����û�е���0���Ǻͺ���Ĵ����йأ�����˴�����Ϊ0����ô���0Ѫ0�Ƶ������̩˫��������Ai��Υ���ճǵĹ���
	if shou:hasSkill("kongcheng") and shou:isKongcheng() then
	    pre = -100
	end
	return pre
end
	
--һ��Ϊѯ���Ƿ񷢶�������Ai�Ĵ���
sgs.ai_skill_invoke.ayjisu = function(self, data)
	local besttarget --�����������ս�ɫ����Ѵ�����ɫ�ʹ�����ɫ
	local target
	self:sort(self.enemies,"hp") --���ｲ���˰�������ֵ����Ҳ�ɰ�����ֵ������Ҳ��֪���Ǹ�������Щ
	--���£�Ѱ����ѱ�ɱ����ѡ������Ҵ˼���һ����������п��ܾͱ��������ˣ���ô��ѡ����
	for _,enemy in ipairs(self.enemies) do
	    if sgs.getDefense(enemy) < 6 and slashdamage(self,self.player,enemy) >= enemy:getHp() then
		    besttarget = enemy
			break
	    end
	end
	--���£�Ѱ��һ�����Ե���ѡ
	for _,enemy in ipairs(self.enemies) do
	    if sgs.getDefense(enemy) < 8 and slashdamage(self,self.player,enemy) > 0 then
		    target = enemy
			break
	    end
	end
	--���£�ȷ����Ҫ�������ܣ������ɱ˭
	--���������Ѵ�����ɫ��������һ���ᷢ����
	--����㲻����Ѵ����ߣ���ô��Ҫ������������״̬������û�п����ж����͹�����Χ��û�˶����͵������������Ϊ�Ҳ�֪����ο���
	if besttarget then
	    self.room:setPlayerFlag(besttarget, "jisu_target")
		return true
	elseif target and sgs.getDefense(self.player) > 8 then
	    self.room:setPlayerFlag(target, "jisu_target")
		return true
	else
	    return false
	end
	return false
end

--������ѯ�� ��ѡ���ٵ�Ŀ�� ʱ��AI��ѡ��
--���ҵ������Ѿ����ϱ�ǵ���ң�Ȼ��ѡ��������
sgs.ai_skill_playerchosen.ayjisu = function(self, targets)
	local target
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if player:hasFlag("jisu_target") then
			target = player
			self.room:setPlayerFlag(target, "-jisu_target")
		end
	end
	return target
end

--��������ֹ���˶�ӵ�м��� ˮӾ ����ʹ�� ��ɱ
--���������˺���������ֱ��޸��� �𹥣���ȸ���������� ������������Ӧλ�ò鿴�޸ĺۼ�
--û�п������� ����������� �����������⣬����������ôϸ��
function sgs.ai_slash_prohibit.ayshuiyong(self, to, card)
	if card:isKindOf("FireSlash") then return true end
	return false
end
--����ֵ
sgs.ai_chaofeng.ayyeshiwen = 1

--�����Ǹ���AI��ˮ������ӵ������Ҫװ���ƣ�AI�ڷ����ʵ¡��żƼ���ʱ���������
sgs.ai_cardneed.ayshuijian = sgs.ai_cardneed.equip
--����ֵ
sgs.ai_chaofeng.aysunyang = 2