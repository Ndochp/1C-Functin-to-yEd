﻿
Процедура КнопкаВыполнитьНажатие(Кнопка)
	
	ТекстМодуля = ЭлементыФормы.ТекстМодуля.ПолучитьТекст();
	Результат = РазобратьТекстМодуля(ТекстМодуля);
	
	Если ТипЗнч(Результат) = Тип("Строка") Тогда
		Предупреждение(Результат);
	Иначе
		Закрыть(Результат);
	КонецЕсли;
	
КонецПроцедуры

