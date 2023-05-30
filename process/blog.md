# Blog Posts about *Epic Sax Game*

## You Break It You Broke It (2012-02-24)

Having released *You Say Jump I Say How High* into the wild today, I was thinking about the nature of things being "broken" in games, given that that game naturally allows you to break it. Pick a speed high enough and you'll go flying through walls without touching them, for instance. (Hilariously, there's already a complaint that you can "win" the game by setting speed to 50,000 and hitting the right arrow key on each level &#8211; this is part of why players are awesome.) Anyway, the game is, in that sense, broken, or rather it's breakable.

<!--more-->

And in fact straight after finishing *You Say Jump* I started the next project, or kind of returned to it: a music game based on Epic Sax Guy. Called *Epic Sax Game*. Like *You Say Jump* it seems to have some properties of brokenness &#8211; in this case the nature of playing multiple sound files in flash &#8211; at some points it just seems to get utterly confused. But it only gets confused it you slam the keys willy nilly *trying* to mess things up. This raises the question of why we think we should be allowed to do that in games. Or, rather, why do we think we should be able to do that and have the game *still* not break?

Of course, this is all part of the inheritance of usability from traditional software design and development, and thus (as has been pointed out by smarter people than me, like Bill Gaver), the inheritance of *work*. In working, we expect efficiency, easy of use, and certainly stability. We assume these are qualities that all software should have, and yet they certainly aren't qualities *inherent* to software and the development process, quite the opposite. Of course, it's absurd to suggest that software/games should just be a mess of bugs and random crashes, but the notion of a kind of zero-tolerance, particularly in a creative medium like games, strikes me as rather limited and limiting.

In fact, I might argue that this relates to the idea of "technology as material" (read Tom Armitage's great piece on that [here](http://infovore.org/archives/2011/08/22/technology-as-a-material/)). In striving to erase all signs of error or frailty in code/games, in one way we're attempting to deny their material nature, as if we want to pretend they're not *made of anything*, that they just spring into existence. In opposition to that, I find the idea of elements of games which are somewhat broken (without utterly breaking the experience) help to make them more "material", and thus interesting in a particular kind of way.

If I was going to say there was anything "important" about what I was trying to do in making *You Say Jump I Say How High* it might be this relationship to technology/games as a material. In giving the player the ability not just to tweak physics variables for fun and entertainment, but also the potential to break the fabric of the (inner) game itself, I'd hope there's a corresponding experience of the outer shell of the game, the substance it's made of. It's true that you can set the speed to 50,000 and hit the right arrow to complete every level.

But what does it *mean*?

## The Pursuit of Excellentish (2012-02-29)

Making surprisingly good headway into the new game. As ever, I've found myself reluctant to say what it is, which is some kind of totally absurd secrecy behaviour I barely understand. So, anyway, it's a game interpretation of [Epic Sax Guy](http://www.youtube.com/watch?v=KHy7DGLTt8g), called *Epic Sax Game*. It started off as a super simple version, but I've ended up adding a bunch of different "levels" and I feel kind of excited about it just at the moment (pending the despair I will necessarily feel in a week's time or whatever). One thing that's happened, though, and happens with some frequency in my game making, is getting *massively sidetracked* by technology-related stuff that is ultimately a bit irrelevant to the game itself.

<!--more-->

In the current game, I occasionally dive off into obsession with making the looping music in the game loop *just right*. Flash actually has some pretty amazing problems with properly looping music, and there are all kind of arcane and tech-y solutions out there. Which is all fine, and I've wandered those alleys extensively, except that I don't *need* perfectly looping music for the game. Or, rather, the *idea* of the game, the *point* of it, doesn't hinge on perfectly looping music. So to the extent that I care about making games because I want to convey an idea or a joke or a whatever, then why should I burn so much time on technical details?

I shouldn't.

And that's not to say that nobody should. Instead, it's a characterisation of what I personally find important about making games, and thus a reminder to myself of where to focus my energies. It's always going to be tempting to hone different technology elements to a fine point, because, well, because you can &#8211; that's part of the meta-game of programming a game. But the meta-game I'm interested in playing doesn't involve that stuff, it involves thinking through ideas/experiences and getting them out there as quickly as I can to convey the ideas/experiences to other people.

So. Dear Future Me, please don't get obsessed with technology/coding solutions in the midst of making a fairly simply game. I mean, I know that you will, but try to be more self-aware and pull out of it a bit earlier, if you could? Don't spend a week fiddling with Box2D to no particular end if you could avoid it. Don't worry quite so much about ultra-precise beat matching for a rhythm game.

I don't mean don't *polish*, do that a fair bit. But don't polish so much that there's nothing left of the spark at the end. You need a few edges to catch on, anyway.

Thanks.

## Making Conserves in the Weekend (2012-03-03)

This morning Rilla suggested that we have a bit of a "game jam" at a weekend activity, so we did! We'd been inspired by the speed with which we saw Photon Storm putting together a version of Atari-style breakout so we set out to come up with our own versions of the game to modify it with, based on the generalised idea of it being multiplayer and preferably collaborative. For one reason or another I couldn't quite get to the collaborative bit, but I did manage to put together a two-player Breakout in an hour or two.

<!--more-->

It was pretty liberating trying to just make something extremely simply, and it was a great moment when I realised that the bricks themselves could be controlled by one of the characters. From there, making the game was eerily simple, since Flixel in particular makes a bunch of things very straightforward. Couple of tweaks and there it was, pretty much, with some small decisions about how to handle oddities like the ball weirdly getting pushed off the screen by Flixel's collision detection and so on. A working game.

Playtested it a tiny bit at Gordon's place and found out that the bricks were ridiculously overpowered, which is in itself, a hilarious thing to say about Breakout. With the help of Gordon, Rilla, and Tue, decided that the bricks should have the corresponding disadvantage of mass: being slow. That helps a lot in terms of not being able to so easily just sling the ball off at awkward angles at the beginning of the game, while allowing the bricks to be more versatile and speedy toward the end &#8211; it turns into Pong where one person's paddle is dissolving.

The overall experience was interesting because it felt like another odd step into game making "authenticity". I'm always amazed when people like Terry Cavanagh and Increpare churn out games like nobody's business, just casually as if they were making a sandwich. So it's nice to have at least sort of accomplished something along those lines and felt how it can be quite satisfying. It was a welcome distraction from the "larger" project of *Epic Sax Game* for instance, which still has a ways to go before it's ready (though hopefully not a huge amount).

I suspect that these little jams might form a more regular part of life. Rilla's working on a more sophisticated, collaborative multiplayer version of Breakout as well, so will be interesting to see where she takes that.

## Putting on a Show (2012-03-06)

One of the weirder aspects of making *Epic Sax Game* so far (and there have been many) has been putting together the Eurovision level of the game. As soon as the game expanded beyond the simple idea of playing the basic loop, it became clear that the player should be able to take part in the Eurovision performance of the full song. But doing so would mean actually *staging* the Eurovision performance all by myself. With pixels.

<!--more-->

And so I've been working away at it over the last few days, drawing dance moves and light shows and stage scenery with as much fidelity to the real show as I can manage without sacrificing my entire life to it. That process of working out which elements to take and which to invent has been an intriguing one. In particular, the whole time it's felt like *I* am stage directing a show of my own &#8211; you go there, you guys jump in the air, let's have a big flash of light now! I watch and rewatch videos of the real performance repeatedly, looking for subtleties that will help to make it feel like the real deal during gameplay. I get lost in questions of how important it is to have the violinist rotating at the beginning (Very Important) or whether people need to walk around on stage (hell no, too hard).

If nothing else, it's given me a deep appreciation for how much work goes into putting on one of these events. We sit in front of Eurovision shows and chuckle away about how cheesy they are and shout "next!" at the TV and so on. But no, those people worked their asses off, and people planned the various moves, the lighting, the fireworks, and everything! Now that I *am* all those people, I feel an abiding sympathy and, perhaps perversely, I now *really* enjoy watching the Moldovan performance in Eurovision 2010, despite having watched it around 100 times by now perhaps.

In short, as ever, game making gives you these strange tastes of other occupations and lives. I'm pretty sure I never thought I'd find myself sympathising with Eurovision choreographers and stage directors, and yet here I am, watching their handiwork and thinking...

"My brothers. My sisters."

## I Got Mired in a Fever (2012-03-11)

Hotter than a pepper sprout. Yeah, have been kind of soul-crushingly sick for the last several days. Seems to be abating now, but that's why I missed blog posts last week. I think I'll be good to restart tomorrow, and I *did* keep working on *Epic Sax Game* regardless, mopping my brow like a hero, shifting mountains of code without complaint, pushing pixels.

## Return (2012-03-26)

Alright, fine, I fell off the wagon. Or back onto the wagon. Or something concerning the wagon. But now I am *driving* the wagon because I am back in charge. After having been feverish and ill for a week, and then being in Greece for a week, and then other stuff for a few days, I am fully in possession of my blogging faculties. I am also in possession of an essentially completed *Epic Sax Game*, so I'll release that in the next day or so (doing battle with a couple of last bugs). Looking forward to writing a few things about my intentions with the game, because I suspect it won't be overly popular, seeing as how it's a bit difficult in an odd way. Anyway, that's the plan. Stay tuned if you like!

## The Epic Work Game (2012-03-27)

So, I released *Epic Sax Game* into the wild today. Although it seems to me that I've been working on it *forever*, I can see by looking at my "records" that in fact it took about two weeks of insane work to get the majority of the game done, one week of illness and a minor nervous breakdown, and one week of polish. So, say three weeks of pretty solid work to put it together.

<!--more-->

I'm not really clear on how many hours a day I spend on these games when I'm really engaged, but I think it must be on the order of four to five hours a day, seven days a week, worryingly enough. So that's about 28 &#8211; 35 hours a week, bordering on a full time job in my "spare time". That's interesting to me because, in the absence of running such numbers, I have the strong sensation that I simply *don't work hard enough* on my games and that I should be more committed. Seems to be not so true. It's probably worth checking these things.

The other thing that *Epic Sax Game*, *Two Player Breakout*, and this afternoon's luck in putting together an interesting example game for my class, have indicated is that I am, thankfully, getting better at the technical elements of this crazy game called... uh, games. This is good because the learning process for all of this was, frankly, very hard. Getting the chops to make even a rudimentary "thing" in Flixel was a bit freaky, for instance, but now I feel largely at home within its framework and even noodle around in the code of the library itself, trying to establish what's going on (and failing, but that's okay).

Beyond all that, I'm repeatedly astonished by the amount of sheer work games are, and simultaneously by how much of the time that work feels kind of effortless (the other times it feels like a waking nightmare, to be fair). But by goodness you end up doing a lot if you're tackling a game on your own. For *Epic Sax Game* alone I spent many, many hours coding of course, but then also drawing character sketches, making animations, editing MIDI files, manipulating sound files, following rabbit holes of gapless looping code, debugging, stress testing, learning to play my own virtual saxophone, stage directing Eurovision 2010, recreating a YouTube video, ... whoa.

It's nice, then, after all that, that the main thing I'm thinking (other than some amount of satisfaction with a game done) is all about the next project, which I have already started. More on *Epic Sax Game* and what it "means" tomorrow.

## Meaningful Sax (2012-03-28)

*Epic Sax Game* has been out for a bit over a day and, wonderfully enough, has found a pretty receptive audience! I thought I should put down some words about what I see the game as being "about" before I forget all about it all and move on to the next project, called (for now) *PONGS*.

<!--more-->

So, as has been the case with past games (notably *The Artist Is Present*), *Epic Sax Game* started with the very clear understanding that a game that was somehow based on Epic Sax Guy and his marvelous looping saxophone refrain would be a great thing. A thing that would need to exist in the world. So initially, at least, the idea revolved around a simple game in which you would play the refrain on your keyboard, synched up to the music and while watching some sort of representation of the Sax Guy. I actually first thought of it as looking a bit like the BIT.TRIP games, with the image degrading and improving based on your performance.

However, during actual development various salient details of making the game came up that changed my direction. For one thing, I was super intimidated by the idea of BIT.TRIP like visuals and decided to go for a more straightforward "little pixel dude playing a saxophone", which was more within my skill set. For another thing, I rather quickly discovered that it was pretty freakin' hard to play the saxophone refrain. Thus, a moment of crisis. Should I find a way to make it easier/"fairer", or do I stick to the basics of "one key one note"? Because it was a) easier and b) truer to the spirit of making my games as unapologetic as I can muster, I went with the note-for-note approach. But this led to a new view of the game, it had taken a turn toward *musical* *performance*, rather than the idea of a game that you play.

That pretty much changed my view of what I was doing from "funny representation of Epic Sax" to (without trying to sound too pretentious!) a kind of "investigation" of the performance, and providing the player with a way of tapping into that more than just a kind of distanced player-avatar thing. In that way, the idea of the different "levels" of the game came about. The practice mode was necessary just because you needed a free place to just learn the loop (which isn't easy after all), and it made sense this was Epic Sax Guy practicing at home. From there it was possible to escalate to the Studio and Eurovision and YouTube, while also providing some down time in the Jam Session. However, the game never enforces some idea that you have to play "well" &#8211; so you can just play the saxophone any damn way you like in any of the levels, which is an important aspect of performance: there might be a script, but you can step outside it because you have agency.

Ahem.

Anyway, I guess that in short I wanted to say that from a game that was a chuckle about the brilliant Epic Sax Guy meme, I ended up thinking about how a player could be a musical performer (this despite not really knowing a lot about music), and how that related to gameplay and to the sensations/experiences we might have while playing. That was particularly important to me in the Eurovision mode, as I found myself labouring over the stage direction and lighting and choreography to create a situation in which you felt like your performance was *important* and, yes, *epic* (again, whether or not you chose to play the official notes). From the comments I've seen on the game so far, I think this was actually remarkably successful, so that's pretty intriguing!

Perhaps more on all this tomorrow, or perhaps something else.
