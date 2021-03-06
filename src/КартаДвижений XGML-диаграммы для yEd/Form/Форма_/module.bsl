﻿Функция ПолучитьТаблицуРегистров()

	Таблица = Новый ТаблицаЗначений;
	Таблица.Колонки.Добавить("ВидДокумента");
	Таблица.Колонки.Добавить("Регистр");
	Таблица.Колонки.Добавить("ВидРегистра");
	
	Для Каждого мДокумент Из Метаданные.Документы Цикл
		
		ВидДокумента = мДокумент.Имя;
		
		Для Каждого мДвижение Из мДокумент.Движения Цикл
			
			Строка = Таблица.Добавить();
			Строка.ВидДокумента = ВидДокумента;
			Строка.Регистр = мДвижение.Имя;
			Строка.ВидРегистра = ОпределитьВидРегистра(мДвижение);
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат Таблица;

КонецФункции // ПолучитьТаблицуРегистров()

Функция ОпределитьВидРегистра(мДвижение)
	
	Перем ЗначениеВозврата;
	
	Если Метаданные.РегистрыБухгалтерии.Содержит(мДвижение) Тогда
		ЗначениеВозврата = "РегистрБухгалтерии";
	ИначеЕсли Метаданные.РегистрыНакопления.Содержит(мДвижение) Тогда
		ЗначениеВозврата = "РегистрНакопления";
	ИначеЕсли Метаданные.РегистрыРасчета.Содержит(мДвижение) Тогда
		ЗначениеВозврата = "РегистрРасчета";
	ИначеЕсли Метаданные.РегистрыСведений.Содержит(мДвижение) Тогда
		ЗначениеВозврата = "РегистрСведений";
	КонецЕсли;
	
	Возврат ЗначениеВозврата;
		
КонецФункции // ОпределитьВидРегистра()

Функция ПолучитьТекстXGML()

	ТаблицаРегистров = ПолучитьТаблицуРегистров();
	
	СводнаяТаблица = ТаблицаРегистров.Скопировать(, "Регистр, ВидРегистра");
	СводнаяТаблица.Свернуть("Регистр, ВидРегистра");
	
	ТекстЗапроса = "";
	Для Каждого СтрокаТаблицы Из СводнаяТаблица Цикл
		
		ТекстЗапроса = ТекстЗапроса + ?(ПустаяСтрока(ТекстЗапроса), "", "
		|	ОБЪЕДИНИТЬ ВСЕ
		|") + ПолучитьТекстЗапроса(СтрокаТаблицы.Регистр, СтрокаТаблицы.ВидРегистра);
		
	КонецЦикла;
	
	Если ПустаяСтрока(ТекстЗапроса) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТекстЗапроса = ТекстЗапроса + "
	|ИТОГИ
	|	СУММА(КоличествоДокументов)
	|ПО
	|	ВидРегистра,
	|	ИмяРегистра";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	
	Возврат ОбработататьРезультатЗапроса(Запрос.Выполнить());
	
КонецФункции// ТекстXGML()

Функция ОбработататьРезультатЗапроса(Результат)

	Если Результат.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	КэшРегистраторы = Новый Соответствие;
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку();
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("section");
	ЗаписьXML.ЗаписатьАтрибут("name", "xgml");
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("section");
	ЗаписьXML.ЗаписатьАтрибут("name", "graph");
	
	СоздатьГруппуXGML(ЗаписьXML, "Документы", "Документы");
	
	ВидыРегистров = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВидыРегистров.Следующий() Цикл
		
		ВидРегистра = ВидыРегистров.ВидРегистра;
		СоздатьГруппуXGML(ЗаписьXML, ВидРегистра);
		
		Регистры = ВидыРегистров.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока Регистры.Следующий() Цикл
			
			ИмяРегистра = Регистры.ИмяРегистра;
			СоздатьЭлементXGML(ЗаписьXML, ИмяРегистра, ВидРегистра);
			
			Регистраторы = Регистры.Выбрать();
			Пока Регистраторы.Следующий() Цикл
				ВидДокумента = Строка(Регистраторы.ВидДокумента);
				Если НЕ ЗначениеЗаполнено(КэшРегистраторы[ВидДокумента]) Тогда
					СоздатьЭлементXGML(ЗаписьXML, ВидДокумента, "Документы");
					КэшРегистраторы.Вставить(ВидДокумента, Истина);
				КонецЕсли;
				
				СоздатьСвязьXGML(ЗаписьXML, ВидДокумента, ИмяРегистра);
				
			КонецЦикла;
			
		КонецЦикла;
		
	КонецЦикла;
	
	ЗаписьXML.ЗаписатьКонецЭлемента(); //graph
	
	ЗаписьXML.ЗаписатьКонецЭлемента(); //xgml
	
	Возврат ЗаписьXML.Закрыть();

КонецФункции // ОбработататьРезультатЗапроса()

Процедура СоздатьСвязьXGML(ЗаписьXML, Начало, Конец)

	ЗаписатьНачалоСекцииXGML(ЗаписьXML, "edge");
	ЗаписатьАтрибутXGML(ЗаписьXML, "source", "string", Начало);
	ЗаписатьАтрибутXGML(ЗаписьXML, "target", "string", Конец);
	
	ЗаписатьНачалоСекцииXGML(ЗаписьXML, "graphics");
	ЗаписатьАтрибутXGML(ЗаписьXML, "fill", "string", "#000000");
	ЗаписатьАтрибутXGML(ЗаписьXML, "targetArrow", "string", "standard");
	ЗаписьXML.ЗаписатьКонецЭлемента(); //graphics
	
	ЗаписьXML.ЗаписатьКонецЭлемента(); //edge

КонецПроцедуры // СоздатьСвязьXGML()

Процедура СоздатьЭлементXGML(ЗаписьXML, ИмяЭлемента, ГруппаЭлемента = "");

	ЗаписатьНачалоСекцииXGML(ЗаписьXML, "node");
	
	ЗаписатьАтрибутXGML(ЗаписьXML, "id", "string", ИмяЭлемента);
	ЗаписатьАтрибутXGML(ЗаписьXML, "label", "string", ИмяЭлемента);
	
	ЗаписатьНачалоСекцииXGML(ЗаписьXML, "graphics");
	ЗаписатьАтрибутXGML(ЗаписьXML, "type", "string", "rectangle");
	ЗаписатьАтрибутXGML(ЗаписьXML, "fill", "string", "#FFCC00");
	ЗаписатьАтрибутXGML(ЗаписьXML, "outline", "string", "#000000");
	ЗаписьXML.ЗаписатьКонецЭлемента(); //graphics
	
	ЗаписатьНачалоСекцииXGML(ЗаписьXML, "LabelGraphics");
	ЗаписатьАтрибутXGML(ЗаписьXML, "text", "String", ИмяЭлемента);
	ЗаписатьАтрибутXGML(ЗаписьXML, "fontSize", "int", "12");
	ЗаписьXML.ЗаписатьКонецЭлемента(); //LabelGraphics
	
	Если НЕ ПустаяСтрока(ГруппаЭлемента) Тогда
		ЗаписатьАтрибутXGML(ЗаписьXML, "gid", "String", ГруппаЭлемента);
	КонецЕсли;
	
	ЗаписьXML.ЗаписатьКонецЭлемента(); //node

КонецПроцедуры // СоздатьЭлементXGML()

Процедура СоздатьГруппуXGML(ЗаписьXML, ИмяГруппы, ЗаголовокГруппы = "")

	Если ПустаяСтрока(ЗаголовокГруппы) Тогда
		ЗаголовокГруппы = ИмяГруппы;
	КонецЕсли;
	
	ЗаписатьНачалоСекцииXGML(ЗаписьXML, "node");
	
	ЗаписатьАтрибутXGML(ЗаписьXML, "id", "string", ИмяГруппы);
	ЗаписатьАтрибутXGML(ЗаписьXML, "label", "string", ЗаголовокГруппы);
	
	ЗаписатьНачалоСекцииXGML(ЗаписьXML, "graphics");
	ЗаписатьАтрибутXGML(ЗаписьXML, "type", "string", "roundrectangle");
	ЗаписатьАтрибутXGML(ЗаписьXML, "fill", "string", "#F5F5F5");
	ЗаписатьАтрибутXGML(ЗаписьXML, "outline", "string", "#000000");
	ЗаписьXML.ЗаписатьКонецЭлемента(); //graphics
	
	ЗаписатьНачалоСекцииXGML(ЗаписьXML, "LabelGraphics");
	ЗаписатьАтрибутXGML(ЗаписьXML, "text", "String", ЗаголовокГруппы);
	ЗаписатьАтрибутXGML(ЗаписьXML, "fill", "String", "#EBEBEB");
	ЗаписатьАтрибутXGML(ЗаписьXML, "fontSize", "int", "14");
	ЗаписатьАтрибутXGML(ЗаписьXML, "anchor", "String", "t");
	ЗаписьXML.ЗаписатьКонецЭлемента(); //LabelGraphics
	
	ЗаписатьАтрибутXGML(ЗаписьXML, "isGroup", "boolean", "true");
	
	ЗаписьXML.ЗаписатьКонецЭлемента(); //node

КонецПроцедуры // СоздатьГруппуXGML()

Процедура ЗаписатьНачалоСекцииXGML(ЗаписьXML, name)

	ЗаписьXML.ЗаписатьНачалоЭлемента("section");
	ЗаписьXML.ЗаписатьАтрибут("name", name);

КонецПроцедуры // ЗаписатьНачалоСекции()

Процедура ЗаписатьАтрибутXGML(ЗаписьXML, key, type, text)
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("attribute");
	ЗаписьXML.ЗаписатьАтрибут("key", key);
	ЗаписьXML.ЗаписатьАтрибут("type", type);
	ЗаписьXML.ЗаписатьТекст(text);
	ЗаписьXML.ЗаписатьКонецЭлемента(); //attribute
	
КонецПроцедуры // ЗаписатьАтрибутXGML()

Функция ПолучитьТекстЗапроса(ИмяРегистра, ВидРегистра)
	
	ВидРегистраСтрока = """" + ВидРегистра + """";
	ИмяРегистраСтрока = """" + ИмяРегистра + """";
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ТИПЗНАЧЕНИЯ(Движения.Регистратор) КАК ВидДокумента,
	|	" + ВидРегистраСтрока+ " КАК ВидРегистра,
	|	" + ИмяРегистраСтрока+ " КАК ИмяРегистра,
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Движения.Регистратор) КАК КоличествоДокументов
	|ИЗ
	|	"+ВидРегистра+"."+ИмяРегистра+" КАК Движения
	|
	|СГРУППИРОВАТЬ ПО
	|	ТИПЗНАЧЕНИЯ(Движения.Регистратор)";
	
	Возврат ТекстЗапроса;
	
КонецФункции

Процедура КнопкаВыполнитьНажатие(Кнопка)
ЭлементыФормы.ТекстXGML.УстановитьТекст(ПолучитьТекстXGML());
КонецПроцедуры
