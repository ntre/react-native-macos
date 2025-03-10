/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @format
 * @flow
 */

'use strict';

const RNTesterExampleFilter = require('./RNTesterExampleFilter');
const RNTesterComponentTitle = require('./RNTesterComponentTitle');
const React = require('react');

const {
  Platform,
  PlatformColor,
  SectionList,
  StyleSheet,
  Text,
  TouchableHighlight,
  Image,
  View,
} = require('react-native');

import {RNTesterThemeContext} from './RNTesterTheme';

const ExampleCard = ({
  onShowUnderlay,
  onHideUnderlay,
  item,
  toggleBookmark,
  handlePress,
}) => {
  const theme = React.useContext(RNTesterThemeContext);
  const platform = item.module.platform;
  const onIos = !platform || platform === 'ios';
  const onAndroid = !platform || platform === 'android';
  return (
    <TouchableHighlight
      onShowUnderlay={onShowUnderlay}
      onHideUnderlay={onHideUnderlay}
      focusable={false} // TODO(macOS GH#774)
      accessibilityLabel={item.module.title + ' ' + item.module.description}
      style={styles.listItem}
      underlayColor={'rgb(242,242,242)'}
      onPress={() =>
        handlePress({exampleType: item.exampleType, key: item.key})
      }>
      <View
        style={[styles.row, {backgroundColor: theme.SystemBackgroundColor}]}>
        <View style={styles.topRowStyle}>
          <RNTesterComponentTitle>{item.module.title}</RNTesterComponentTitle>
          <TouchableHighlight
            style={styles.imageViewStyle}
            onPress={() =>
              toggleBookmark({exampleType: item.exampleType, key: item.key})
            }>
            <Image
              style={styles.imageStyle}
              source={
                item.isBookmarked
                  ? require('../assets/bookmark-outline-blue.png')
                  : require('../assets/bookmark-outline-gray.png')
              }
            />
          </TouchableHighlight>
        </View>
        <Text
          style={[
            styles.rowDetailText,
            {color: theme.SecondaryLabelColor, marginBottom: 5},
          ]}>
          {item.module.description}
        </Text>
        <View style={styles.bottomRowStyle}>
          <Text style={{color: theme.SecondaryLabelColor, width: 65}}>
            {item.module.category || 'Other'}
          </Text>
          <View style={styles.platformLabelStyle}>
            <Text
              style={{
                color: onIos ? '#787878' : theme.SeparatorColor,
                fontWeight: onIos ? '500' : '300',
              }}>
              iOS
            </Text>
            <Text
              style={{
                color: onAndroid ? '#787878' : theme.SeparatorColor,
                fontWeight: onAndroid ? '500' : '300',
              }}>
              Android
            </Text>
          </View>
        </View>
      </View>
    </TouchableHighlight>
  );
};

const renderSectionHeader = ({section}) => (
  <RNTesterThemeContext.Consumer>
    {theme => {
      return (
        <Text
          style={[
            styles.sectionHeader,
            {
              color: theme.SecondaryLabelColor,
              backgroundColor: theme.GroupedBackgroundColor,
            },
          ]}>
          {section.title}
        </Text>
      );
    }}
  </RNTesterThemeContext.Consumer>
);

const RNTesterExampleList: React$AbstractComponent<any, void> = React.memo(
  ({sections, toggleBookmark, handleExampleCardPress}) => {
    const theme = React.useContext(RNTesterThemeContext);

    const filter = ({example, filterRegex, category}) =>
      filterRegex.test(example.module.title) &&
      (!category || example.category === category) &&
      (!Platform.isTV || example.supportsTVOS);

    const renderListItem = ({item, section, separators}) => {
      return (
        <ExampleCard
          item={item}
          section={section}
          onShowUnderlay={separators.highlight}
          onHideUnderlay={separators.unhighlight}
          toggleBookmark={toggleBookmark}
          handlePress={handleExampleCardPress}
        />
      );
    };

    return (
      <View
        style={[
          styles.listContainer,
          {backgroundColor: theme.SecondaryGroupedBackgroundColor},
        ]}>
        <RNTesterExampleFilter
          testID="explorer_search"
          page="components_page"
          sections={sections}
          filter={filter}
          render={({filteredSections}) => (
            <SectionList
              sections={filteredSections}
              extraData={filteredSections}
              renderItem={renderListItem}
              ItemSeparatorComponent={ItemSeparator}
              keyboardShouldPersistTaps="handled"
              focusable={true} // TODO(macOS GH#774)
              enableSelectionOnKeyPress={true} // TODO(macOS GH#774)
              automaticallyAdjustContentInsets={false}
              keyboardDismissMode="on-drag"
              renderSectionHeader={renderSectionHeader}
              ListFooterComponent={() => <View style={{height: 80}} />}
            />
          )}
        />
      </View>
    );
  },
);

const ItemSeparator = ({highlighted}) => (
  <RNTesterThemeContext.Consumer>
    {theme => {
      return (
        <View
          style={
            highlighted
              ? [
                  styles.separatorHighlighted,
                  {backgroundColor: theme.OpaqueSeparatorColor},
                ]
              : [styles.separator, {backgroundColor: theme.SeparatorColor}]
          }
        />
      );
    }}
  </RNTesterThemeContext.Consumer>
);

const styles = StyleSheet.create({
  listContainer: {
    flex: 1,
  },
  list: {
    ...Platform.select({
      // [TODO(macOS GH#774)
      macos: {
        backgroundColor: PlatformColor('controlBackgroundColor'),
      },
      ios: {
        backgroundColor: PlatformColor('systemBackgroundColor'),
      },
      default: {
        // ]TODO(macOS GH#774)
        backgroundColor: '#eeeeee',
      }, // [TODO(macOS GH#774)
    }), // ]TODO(macOS GH#774)
  },
  listItem: {
    backgroundColor: Platform.select({ios: '#FFFFFF', android: '#F3F8FF'}),
  },
  sectionHeader: {
    ...Platform.select({
      // [TODO(macOS GH#774)
      macos: {
        backgroundColor: {
          semantic: 'unemphasizedSelectedContentBackgroundColor',
        },
        color: PlatformColor('headerTextColor'),
      },
      ios: {
        backgroundColor: {
          semantic: 'systemGroupedBackgroundColor',
        },
        color: PlatformColor('secondaryLabelColor'),
      },
      default: {
        // ]TODO(macOS GH#774)
        backgroundColor: '#eeeeee',
        color: 'black',
      }, // [TODO(macOS GH#774)
    }), // ]TODO(macOS GH#774)
    padding: 5,
    fontWeight: '500',
    fontSize: 11,
  },
  row: {
    justifyContent: 'center',
    paddingHorizontal: 15,
    paddingVertical: 12,
    marginVertical: Platform.select({ios: 4, android: 8}),
    marginHorizontal: 15,
    overflow: 'hidden',
    elevation: 5,
  },
  selectedRow: {
    // [TODO(macOS GH#774)
    backgroundColor: '#DDECF8',
    justifyContent: 'center',
    paddingHorizontal: 15,
    paddingVertical: 8,
  }, // ]TODO(macOS GH#774)
  separator: {
    height: Platform.select({ios: StyleSheet.hairlineWidth, android: 0}),
    marginHorizontal: Platform.select({ios: 15, android: 0}),
    ...Platform.select({
      // [TODO(macOS GH#774)
      macos: {
        backgroundColor: PlatformColor('separatorColor'),
      },
      ios: {
        backgroundColor: PlatformColor('separatorColor'),
      },
      default: {
        // ]TODO(macOS GH#774)
        backgroundColor: '#bbbbbb',
      }, // [TODO(macOS GH#774)
    }), // ]TODO(macOS GH#774)
  },
  separatorHighlighted: {
    height: StyleSheet.hairlineWidth,
    backgroundColor: 'rgb(217, 217, 217)',
  },
  sectionListContentContainer: Platform.select({
    // [TODO(macOS GH#774)
    macos: {backgroundColor: PlatformColor('separatorColor')},
    ios: {backgroundColor: PlatformColor('separatorColor')},
    default: {backgroundColor: 'white'},
  }), // ]TODO(macOS GH#774)
  rowTitleText: {
    fontSize: 17,
    fontWeight: '500',
    ...Platform.select({
      // [TODO(macOS GH#774)
      macos: {
        color: PlatformColor('controlTextColor'),
      },
      ios: {
        color: PlatformColor('labelColor'),
      },
      default: {
        // ]TODO(macOS GH#774)
        color: 'black',
      }, // [TODO(macOS GH#774)
    }), // ]TODO(macOS GH#774)
  },
  topRowStyle: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    flex: 1,
  },
  bottomRowStyle: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  rowDetailText: {
    fontSize: 12,
    lineHeight: 20,
  },
  imageViewStyle: {
    height: 30,
    width: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    bottom: 5,
  },
  imageStyle: {
    height: 25,
    width: 25,
  },
  platformLabelStyle: {
    flexDirection: 'row',
    width: 100,
    justifyContent: 'space-between',
  },
});

module.exports = RNTesterExampleList;
