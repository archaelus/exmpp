% $Id$

-module(check_xml_path).
-vsn('$Revision$').

-include("exmpp.hrl").

-export([check/0, do_check/0]).

check() ->
	do_check(),
	testsuite:pass().

do_check() ->
	test_get_path_special_cases(),
	test_get_path_element(),
	test_get_path_ns_element(),
	test_get_path_attribute(),
	test_get_path_ns_attribute(),
	test_get_path_cdata(),
	test_get_path_ns_cdata(),
	ok.

% --------------------------------------------------------------------
% Path testsuite.
% --------------------------------------------------------------------

-define(XML_NS, 'http://www.w3.org/XML/1998/namespace').

-define(ATTRIBUTE, {xmlattr, ?XML_NS, undefined, "lang", "fr"}).
-define(CDATA, {xmlcdata, <<"Content">>}).

-define(TARGET, {xmlnselement,
	?XML_NS, undefined, "target",
	[?ATTRIBUTE],
	[?CDATA]}
).

-define(ELEMENT1, {xmlnselement,
	?XML_NS, undefined, "element",
	[],
	[]}
).

-define(ELEMENT2, {xmlnselement,
	?XML_NS, undefined, "element",
	[?ATTRIBUTE],
	[?TARGET, ?CDATA]}
).

-define(ELEMENT3, {xmlnselement,
	?XML_NS, undefined, "element",
	[],
	[?ELEMENT2]}
).

test_get_path_special_cases() ->
	testsuite:is(exmpp_xml:get_path(?ELEMENT1,
	    []),
	    ?ELEMENT1),
	testsuite:is(exmpp_xml:get_path(?ELEMENT1,
	    [{attribute, "lang"} | bad_data]),
	    {error, ending_component_not_at_the_end}),
	testsuite:is(exmpp_xml:get_path(?ELEMENT1,
	    [cdata | bad_data]),
	    {error, ending_component_not_at_the_end}),
	testsuite:is(exmpp_xml:get_path(?ELEMENT1,
	    bad_data),
	    {error, invalid_path}),
	ok.

test_get_path_element() ->
	testsuite:is(exmpp_xml:get_path(?ELEMENT1,
	    [{element, "target"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, "target"}]),
	    ?TARGET),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, "target"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, "element"}, {element, "target"}]),
	    ?TARGET),
	ok.

test_get_path_ns_element() ->
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, ?XML_NS, "target"}]),
	    ?TARGET),
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, 'some_other_ns', "target"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "target"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, 'some_other_ns', "target"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "element"},
	     {element, ?XML_NS, "target"}]),
	    ?TARGET),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "element"},
	     {element, 'some_other_ns', "target"}]),
	    ""),
	ok.

test_get_path_attribute() ->
	testsuite:is(exmpp_xml:get_path(?ELEMENT1,
	    [{element, "target"}, {attribute, "lang"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, "target"}, {attribute, "lang"}]),
	    "fr"),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, "target"}, {attribute, "lang"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, "element"}, {element, "target"}, {attribute, "lang"}]),
	    "fr"),
	ok.

test_get_path_ns_attribute() ->
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, ?XML_NS, "target"}, {attribute, "lang"}]),
	    "fr"),
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, "target"}, {attribute, ?XML_NS, "lang"}]),
	    "fr"),
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, 'some_other_ns', "target"}, {attribute, "lang"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, "target"}, {attribute, 'some_other_ns', "lang"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "target"}, {attribute, "lang"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, "target"}, {attribute, ?XML_NS, "lang"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, 'some_other_ns', "target"}, {attribute, "lang"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, "target"}, {attribute, 'some_other_ns', "lang"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "element"},
	     {element, ?XML_NS, "target"}, {attribute, "lang"}]),
	    "fr"),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "element"},
	     {element, "target"}, {attribute, ?XML_NS, "lang"}]),
	    "fr"),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "element"},
	     {element, 'some_other_ns', "target"}, {attribute, "lang"}]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "element"},
	     {element, "target"}, {attribute, 'some_other_ns', "lang"}]),
	    ""),
	ok.

test_get_path_cdata() ->
	testsuite:is(exmpp_xml:get_path(?ELEMENT1,
	    [{element, "target"}, cdata]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, "target"}, cdata]),
	    "Content"),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, "target"}, cdata]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, "element"}, {element, "target"}, cdata]),
	    "Content"),
	ok.

test_get_path_ns_cdata() ->
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, ?XML_NS, "target"}, cdata]),
	    "Content"),
	testsuite:is(exmpp_xml:get_path(?ELEMENT2,
	    [{element, 'some_other_ns', "target"}, cdata]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "target"}, cdata]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, 'some_other_ns', "target"}, cdata]),
	    ""),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "element"},
	     {element, ?XML_NS, "target"}, cdata]),
	    "Content"),
	testsuite:is(exmpp_xml:get_path(?ELEMENT3,
	    [{element, ?XML_NS, "element"},
	     {element, 'some_other_ns', "target"}, cdata]),
	    ""),
	ok.